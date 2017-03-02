//
//  AppDelegate.swift
//  AIOSXDemo
//

import AI
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AI.configure("YOUR_CLIENT_ACCESS_TOKEN")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

