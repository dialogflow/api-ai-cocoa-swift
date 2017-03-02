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
    
    fileprivate var response: QueryResponse? = .none
    
    @IBAction func send(_ sender: AnyObject) {
        AI.sharedService.textRequest(textField.text ?? "").success {[weak self] (response) -> Void in
            self?.response = response
            DispatchQueue.main.async { [weak self] in
                if let sself = self {
                    sself.performSegue(withIdentifier: "ShowResult", sender: sself)
                }
            }
        }.failure { (error) -> Void in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: .none
                    )
                )
                
                self.present(
                    alert,
                    animated: true,
                    completion: .none
                )
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let _ = response {
            return true
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResult" {
            let resultViewController = segue.destination as! ResultViewController
            resultViewController.result = response!
        }
    }
}
