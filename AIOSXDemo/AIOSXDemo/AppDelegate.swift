//
//  AppDelegate.swift
//  AIOSXDemo
//

import AI
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AI.configure("YOUR_CLIENT_ACCESS_TOKEN", "YOUR_SUBSCRIPTION_KEY")
        AI.configure("3485a96fb27744db83e78b8c4bc9e7b7", "cb9693af-85ce-4fbf-844a-5563722fc27f")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

