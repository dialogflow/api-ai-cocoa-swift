//
//  TextRequestViewController.swift
//  AIOSXDemo
//

import AI
import Cocoa

class TextRequestViewController: NSViewController {

    @IBOutlet weak var inputTextField: NSTextField!
    @IBOutlet weak var outputTextField: NSTextField!

    @IBOutlet weak var sendButton: NSButton!

    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    @IBAction func userDidTouchSendButton(sender: NSButton) {
        self.outputTextField.stringValue = ""

        let query = self.inputTextField.stringValue
        let request = AI.sharedService.TextRequest(query)
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

            self?.sendButton.enabled = true
            self?.inputTextField.enabled = true
        }

        self.progressIndicator.startAnimation(self)

        self.sendButton.enabled = false
        self.inputTextField.enabled = false
    }
}
