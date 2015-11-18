//
//  ResultViewController.swift
//  AIDemo
//
//  Created by Kuragin Dmitriy on 18/11/15.
//  Copyright © 2015 Kuragin Dmitriy. All rights reserved.
//

import UIKit
import AI

class ResultViewController: UIViewController {
    var result: QueryResponse!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = "\(result)"
    }
}
