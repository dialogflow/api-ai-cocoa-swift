//
//  AppDelegate.swift
//  AIOSXDemo
//

import AI
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AI.configure("YOUR_CLIENT_ACCESS_TOKEN")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

