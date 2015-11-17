//
//  BufferedOutputStream.swift
//  AI
//
//  Created by Kuragin Dmitriy on 16/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

class BufferedOutputStream: NSObject, NSStreamDelegate {
    private let stream: NSOutputStream
    private var data: NSMutableData = NSMutableData()
    private var offset: Int = 0
    private let mutex: dispatch_queue_t = dispatch_queue_create("com.test.LockQueue", nil)
    
    init(stream: NSOutputStream) {
        self.stream = stream
    }
    
    func open() {
        stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        stream.open()
    }
    
    private var hasDataForWriting: Bool {
        return (data.length - offset) > 0
    }
    
    private func flush() {
        dispatch_sync(mutex, { () -> Void in
            while self.hasDataForWriting {
                let avaiable = self.data.length - self.offset
                
                let buffer = UnsafeMutablePointer<UInt8>(self.data.mutableBytes + self.offset)
                let writen = self.stream.write(buffer, maxLength: avaiable)
            
                if writen > 0 {
                    self.offset += writen
                }
            }
        })
    }
    
    func close() {
        self.flush()
        
        stream.close()
        stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func append(string: String) {
        if let stringData = string.dataUsingEncoding(NSUTF8StringEncoding) {
            dispatch_sync(mutex, { () -> Void in
                self.data.appendData(stringData)
            })
        }
        
        self.fire()
    }
    
    func append(buffer: UnsafeMutablePointer<Int16>, _ size: UInt32) {
        dispatch_sync(mutex, { () -> Void in
            self.data.appendBytes(buffer, length: Int(size))
        })
        self.fire()
    }
    
    func appendData(additionalData: NSData) {
        dispatch_sync(mutex, { () -> Void in
            self.data.appendData(additionalData)
        })
        self.fire()
    }
    
    private func fire() {
        dispatch_sync(mutex, { () -> Void in
            if self.stream.streamStatus == .Open && self.stream.hasSpaceAvailable && self.hasDataForWriting {
                let bytes = UnsafeMutablePointer<UInt8>(self.data.mutableBytes + self.offset)
                let size = self.data.length - self.offset
                
                let writed = self.stream.write(bytes, maxLength: size)
                
                self.offset += writed
            }
        })
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            self.fire()
        default:
            break
        }
    }
}

extension BufferedOutputStream {
    static func boundStreamsWithBufferSize(bufferSize: Int = 1024) -> (inputStream: NSInputStream, outputStream: NSOutputStream) {
            var readStream: Unmanaged<CFReadStream>?;
            var writeStream: Unmanaged<CFWriteStream>?;
            CFStreamCreateBoundPair(kCFAllocatorDefault, &readStream, &writeStream, bufferSize)
            return (readStream!.takeUnretainedValue(), writeStream!.takeUnretainedValue())
    }
}