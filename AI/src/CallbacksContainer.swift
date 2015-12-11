//
//  CallbacksContainer.swift
//  AI
//
//  Created by Kuragin Dmitriy on 12/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

class CallbacksContainer<T> {
    private var callbacks: [(T) -> Void] = []
    private var onResolvecallbacks: [() -> Void] = []
    
    private var state: T?
    
    func resolve(object: T) {
        if state == nil {
            state = object
            
            while onResolvecallbacks.count > 0 {
                let callback = self.onResolvecallbacks.removeAtIndex(0)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback()
                })
            }
        }
        
        self.fire()
    }
    
    private func fire() {
        while callbacks.count > 0 && state != nil {
            let q = self.callbacks.removeAtIndex(0)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                q(self.state!)
            })
        }
    }
    
    func onResolve(fn: () -> Void) {
        onResolvecallbacks.append(fn)
    }
    
    func put(fn: (T) -> Void) {
        callbacks.append(fn)
        
        self.fire()
    }
}