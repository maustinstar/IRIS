//
//  ViewController.swift
//  IRIS iOS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import IRIS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let source = UIImage(named: "Sample.HEIC")!.enhance()!
    }


}

