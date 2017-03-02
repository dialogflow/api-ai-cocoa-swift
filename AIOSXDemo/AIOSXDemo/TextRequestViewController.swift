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

    @IBAction func userDidTouchSendButton(_ sender: NSButton) {
        self.outputTextField.stringValue = ""

        let query = self.inputTextField.stringValue
        let request = AI.sharedService.textRequest(query)
        request.success { [weak self] (response) in
            DispatchQueue.main.async {
                self?.outputTextField.stringValue = "\(response)"
            }
        }.failure { (error) in
            DispatchQueue.main.async {
                let alert = NSAlert(error: error)
                alert.addButton(withTitle: "Cancel")
                alert.alertStyle = NSAlertStyle.warning

                alert.runModal()
            }
        }.resume { [weak self] (_) in
            if let sself = self {
                sself.progressIndicator.stopAnimation(self)

                sself.sendButton.isEnabled = true
                sself.inputTextField.isEnabled = true
            }
        }

        self.progressIndicator.startAnimation(self)

        self.sendButton.isEnabled = false
        self.inputTextField.isEnabled = false
    }
}
