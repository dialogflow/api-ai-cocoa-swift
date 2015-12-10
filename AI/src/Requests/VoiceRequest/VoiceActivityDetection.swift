//
//  VoiceActivityDetection.swift
//  AI
//
//  Created by Kuragin Dmitriy on 16/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

struct ChunkedStack<T> {
    private var array: [T] = []
    private let chunk: Int
    
    init(chunk: Int = 160) {
        self.chunk = chunk
    }
    
    mutating func push(elements: [T]) {
        array.appendContentsOf(elements)
    }
    
    var hasChunk: Bool {
        return array.count >= chunk
    }
    
    mutating func pop() -> [T]? {
        if self.hasChunk {
            let slice = array[0..<chunk]
            array.removeRange(0..<chunk)
            
            return Array(slice)
        }
        
        return .None
    }
}

enum VADState {
    case Unknown
    case Progress
    case EndOfSpeech
}

protocol VAD {
    var state: VADState { get }
    
    func reset()
    func process(data: UnsafeMutablePointer<Int16>, len: UInt32) -> VADState
}

class CrossZeroRateVAD: VAD {
    private let frameLengthMilis: Float = 10.0
    private let noiseFrames = 15
    
    private var noiseEnergy: Float = 0.0
    private let energyFactor: Float = 3.1
    
    private var frameNumber = 0
    private var lastActiveTime: Float = 0
    private let sequenceLength: Float = 0.03
    private let minSequenceCount = 3
    private var lastSequenceTime: Float = 0.0
    private var silenceLengthMilis: Float = 3.5
    private let maxSilenceLengthMilis: Float = 3.5
    
    private(set) var state: VADState = .Unknown
    private var stack: ChunkedStack<Int16> = ChunkedStack<Int16>()
    private var sequenceCounter: Int = 0
    private let minSilenceLengthMilis: Float = 0.8;

    func reset() {
        // TODO: Provide a proper implementation.
    }
    
    private func czCount(samples: [Int16]) -> Int {
        var last = 0
        
        return samples.reduce(0) { (count, sample) -> Int in
            var sign = 0
            if sample > 0 {
                sign = 1
            } else {
                sign = -1
            }
            
            if last != sign {
                last = sign
                return count + 1
            }
            
            return count
        }
    }
    
    private func isActiveFrame(frame: [Int16]) -> Bool {
        frameNumber += 1
        
        let normalizedSamples = frame.map { (sample) -> Float in
            return Float(sample) / Float(Int16.max)
        }
        
        let energy = normalizedSamples.reduce(0.0, combine: +)
        
        let crossZeroRate = czCount(frame)
        
        if frameNumber < noiseFrames {
            noiseEnergy += energy / Float(noiseFrames)
        } else {
            if  energy > max(noiseEnergy, 0.001818) * energyFactor
            {
                if crossZeroRate >= 5 && crossZeroRate <= 15 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func process(data: UnsafeMutablePointer<Int16>, len: UInt32) -> VADState {
        if case .Unknown = state {
            state = .Progress
        }
        
        let samples = Array(UnsafeBufferPointer(start: data, count: Int(len / 2)))
        stack.push(samples)
        
        while stack.hasChunk && state != .EndOfSpeech {
            let chunk = stack.pop()!
            
            let active = self.isActiveFrame(chunk)
            
            let time = Float(frameNumber) * Float(160.0) / Float(16000.0)
            
            if active {
                if lastActiveTime >= 0 && (time - lastActiveTime) < sequenceLength {
                    sequenceCounter += 1
                    
                    if sequenceCounter > minSequenceCount {
                        lastSequenceTime = time
                        silenceLengthMilis = max(minSilenceLengthMilis, silenceLengthMilis - (maxSilenceLengthMilis - minSilenceLengthMilis) / 4.0)
                    }
                } else {
                    sequenceCounter = 1
                }
                
                lastActiveTime = time;
            } else {
                if time - lastSequenceTime > silenceLengthMilis {
                    if lastSequenceTime > 0 {
                        state = .EndOfSpeech
                    } else {
                        state = .EndOfSpeech
                    }
                }
            }
        }
        
        return state
    }
}