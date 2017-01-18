//
//  CallbacksContainer.swift
//  AI
//
//  Created by Kuragin Dmitriy on 12/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import Foundation

class CallbacksContainer<T> {
    fileprivate var callbacks: [(T) -> Void] = []
    fileprivate var onResolvecallbacks: [() -> Void] = []
    
    fileprivate var state: T?
    
    func resolve(_ object: T) {
        if state == nil {
            state = object
            
            while onResolvecallbacks.count > 0 {
                let callback = self.onResolvecallbacks.remove(at: 0)
                DispatchQueue.main.async(execute: { () -> Void in
                    callback()
                })
            }
        }
        
        self.fire()
    }
    
    fileprivate func fire() {
        while callbacks.count > 0 && state != nil {
            let q = self.callbacks.remove(at: 0)
            DispatchQueue.main.async(execute: { () -> Void in
                q(self.state!)
            })
        }
    }
    
    func onResolve(_ fn: @escaping () -> Void) {
        onResolvecallbacks.append(fn)
    }
    
    func put(_ fn: @escaping (T) -> Void) {
        callbacks.append(fn)
        
        self.fire()
    }
}
