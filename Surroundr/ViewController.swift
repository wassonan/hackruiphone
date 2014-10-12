//
//  ViewController.swift
//  Surroundr
//
//  Created by Ben Kropf on 10/11/14.
//  Copyright (c) 2014 benkropf. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startSearch(sender: AnyObject) {
        NSLog("Button pressed")
    }
   }

