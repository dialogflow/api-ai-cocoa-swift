//
//  VoiceRequestViewController.swift
//  AIDemo
//
//  Created by Kuragin Dmitriy on 18/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import AI
import UIKit

class VoiceRequestViewController: UIViewController {

    private var response: QueryResponse? = .None

    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBAction func userDidTouchStartButton(sender: UIButton) {
        let request = AI.sharedService.VoiceRequest(true)
        request.success { [weak self] (response) in
            dispatch_async(dispatch_get_main_queue()) {
                self?.response = response
                self?.performSegueWithIdentifier("ShowResult", sender: self)
            }
        }.failure { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .Alert
                )

                alert.addAction(
                    UIAlertAction(
                        title: "Cancel",
                        style: .Cancel,
                        handler: .None
                    )
                )

                self.presentViewController(
                    alert,
                    animated: true,
                    completion: .None
                )
            }
        }.resume { [weak self] (response) in
            self?.activityIndicatorView.stopAnimating()

            self?.startButton.enabled = true
        }

        self.activityIndicatorView.startAnimating()

        self.startButton.enabled = false
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard (identifier == Details.segueIdentifier) else {
            return false
        }
        guard (self.response != nil) else {
            return false
        }

        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let destinationViewController = segue.destinationViewController as? ResultViewController else {
            return
        }

        destinationViewController.result = response
    }

    // Details

    private struct Details {
        static let segueIdentifier: String = "ShowResult"
    }
}
