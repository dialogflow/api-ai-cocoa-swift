//
//  AudioRecorder.swift
//  AI
//
//  Created by Kuragin Dmitriy on 02/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import AudioToolbox
import AVFoundation

typealias LevelChangedCallback = (Float) -> Void
typealias DataReceivedCallback = (UnsafeMutablePointer<Int16>, UInt32) -> Void
typealias FailedCompletionCallback = (NSError) -> Void

protocol AudioRecorder {
    init(dataReceivedCallback: DataReceivedCallback)
    
    func start()
    func stop()
    
    func handleLevelChanged(levelChangedCallback: LevelChangedCallback)
}

func AudioQueueInputCallback(
    inUserData: UnsafeMutablePointer<Void>,
    inAQ: AudioQueueRef,
    inBuffer: AudioQueueBufferRef,
    inStartTime: UnsafePointer<AudioTimeStamp>,
    inNumberPacketDescriptions: UInt32,
    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>) -> Void
{
    let audioRecorder = unsafeBitCast(inUserData, QueueAudioRecorder.self)
    let buffer = inBuffer.memory
    
    let size = buffer.mAudioDataByteSize
    let sourceData = UnsafePointer<Int16>(buffer.mAudioData)
    
    let destinationData = UnsafeMutablePointer<Int16>.alloc(Int(size))
    
    memcpy(destinationData, sourceData, Int(size))
    
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
        if audioRecorder.isRunning {
            audioRecorder.dataReceivedCallback(destinationData, size)
        }
        destinationData.destroy(Int(size))
    }
    
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
}

private func throwIfError(@autoclosure fn: () -> OSStatus, message: String) throws {
    let status = fn()
    if status != noErr {
        let userInfo = [
            NSLocalizedDescriptionKey: message
        ]
        
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: userInfo)
    }
}

let kNumberRecordBuffers = 3

class QueueAudioRecorder: AudioRecorder {
    private let dataReceivedCallback: DataReceivedCallback
    private var levelChangedCallback: LevelChangedCallback?
    private var failedCompletionCallback: FailedCompletionCallback? {
        didSet {
            if  let error = error,
                let failedCompletionCallback = failedCompletionCallback
            {
                failedCompletionCallback(error)
            }
        }
    }
    
    private var isRunning = false
    private let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
    private var audioQueue: AudioQueueRef!
    
    required init(dataReceivedCallback: DataReceivedCallback) {
        self.dataReceivedCallback = dataReceivedCallback
        
        let channels: UInt32 = 1
        let bitsPerChannel: UInt32 = 16
        
        var format = AudioStreamBasicDescription(
            mSampleRate: 16000.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
            mBytesPerPacket: (bitsPerChannel / 8) * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: (bitsPerChannel / 8) * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: bitsPerChannel,
            mReserved: 0)
        
        var audioQueue: AudioQueueRef = nil
        
        do {
            try throwIfError(AudioQueueNewInput(&format,
                AudioQueueInputCallback,
                UnsafeMutablePointer(unsafeAddressOf(self)), // nil,
                .None,
                .None,
                0,
                &audioQueue), message: "Connot create audio queue.")
        } catch let error as NSError {
            self.stopWithError(error)
        }
        
        let bufferByteSize = 1024
        
        do {
            for _ in 0..<kNumberRecordBuffers {
                var buffer: AudioQueueBufferRef = nil
                try throwIfError(AudioQueueAllocateBuffer(audioQueue, UInt32(bufferByteSize), &buffer), message: "Cannot allocate buffer")
                try throwIfError(AudioQueueEnqueueBuffer(audioQueue, buffer, 0, nil), message: "Cannot enqueue audio buffer")
            }
        } catch let error as NSError {
            self.stopWithError(error)
        }
        
        var value: UInt32 = 1
        let valueSize = UInt32(sizeof(value.dynamicType))
        
        do {
            try throwIfError(
                AudioQueueSetProperty(audioQueue, kAudioQueueProperty_EnableLevelMetering, &value, valueSize),
                message: "Cannot set property kAudioQueueProperty_EnableLevelMetering.")
        } catch let error as NSError {
            self.stopWithError(error)
        }
        
        self.audioQueue = audioQueue
        
        dispatch_source_set_timer(
            timer,
            DISPATCH_TIME_NOW,
            UInt64(1.0 / 30.0 * Double(NSEC_PER_SEC)),
            UInt64(1.0 / 30.0 * Double(NSEC_PER_SEC))
        )
        
        dispatch_source_set_event_handler(timer) {[weak self] () -> Void in
            let channels = Int(format.mChannelsPerFrame)
            
            var dataSize: UInt32 = UInt32(sizeof(AudioQueueLevelMeterState) * channels)
            var levels = [AudioQueueLevelMeterState](count: channels, repeatedValue: AudioQueueLevelMeterState())
            
            do {
                try throwIfError(AudioQueueGetProperty(audioQueue, kAudioQueueProperty_CurrentLevelMeter, &levels, &dataSize), message: "Cannot get property kAudioQueueProperty_CurrentLevelMeter");
            } catch {
                
            }
            
            self?.levelChangedCallback?(levels.first!.mAveragePower)
        }
        
//        #if os(iOS)
//            let session = AVAudioSession.sharedInstance()
//            let category = session.category
//            
//            if !(category == AVAudioSessionCategoryPlayAndRecord || category == AVAudioSessionCategoryRecord) {
//                
//            }
//            
//        #endif
    }
    
    func start() {
        if (!isRunning && error == nil) {
            isRunning = true
            AudioQueueStart(audioQueue, nil)
            dispatch_resume(timer)
        }
    }
    
    private var error: NSError? = .None {
        didSet {
            if  let error = error,
                let failedCompletionCallback = self.failedCompletionCallback {
                    failedCompletionCallback(error)
            }
        }
    }
    
    private func stopWithError(error: NSError) {
        if case .None = self.error {
            self.error = error
        }
        
        self.stop()
    }
    
    func stop() {
        if (isRunning) {
            isRunning = false
            dispatch_source_cancel(timer);
            AudioQueueStop(audioQueue, true);
        }
    }
    
    func handleLevelChanged(levelChangedCallback: LevelChangedCallback) {
        self.levelChangedCallback = levelChangedCallback
    }
    
    func handleFailedCompletion(failedCompletionCallback: FailedCompletionCallback) {
        self.failedCompletionCallback = failedCompletionCallback
    }
}

