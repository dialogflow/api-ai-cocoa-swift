//
//  TextRequestViewController.swift
//  AIDemo
//
//  Created by Kuragin Dmitriy on 18/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import UIKit
import AI

class TextRequestViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    private var response: QueryResponse? = .None
    
    @IBAction func send(sender: AnyObject) {
        AI.sharedService.TextRequest(textField.text ?? "").success {[weak self] (response) -> Void in
            print("IsMainThread: \(NSThread.isMainThread())")
            self?.response = response
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self?.performSegueWithIdentifier("ShowResult", sender: self)
            })
        }.failure { (error) -> Void in
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
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let _ = response {
            return true
        }
        
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowResult" {
            let resultViewController = segue.destinationViewController as! ResultViewController
            resultViewController.result = response!
        }
    }
}
