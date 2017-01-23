//
//  HelpNavigationViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 2/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class HelpNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
