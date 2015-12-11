//
//  VoiceRequestViewController.swift
//  AIOSXDemo
//

import AI
import Cocoa

class VoiceRequestViewController: NSViewController {

    @IBOutlet weak var startButton: NSButton!

    @IBOutlet weak var outputTextField: NSTextField!

    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    @IBAction func userDidTouchStartButton(sender: NSButton) {
        self.outputTextField.stringValue = ""

        let request = AI.sharedService.VoiceRequest(true)
        request.success { [weak self] (response) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.outputTextField.stringValue = "\(response)"
            }
        }.failure { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                let alert = NSAlert(error: error)
                alert.addButtonWithTitle("Cancel")
                alert.alertStyle = NSAlertStyle.WarningAlertStyle

                alert.runModal()
            }
        }.resume { [weak self] (response) in
            self?.progressIndicator.stopAnimation(self)

            self?.startButton.enabled = true
        }

        self.progressIndicator.startAnimation(self)
        
        self.startButton.enabled = false
    }
}
