//
//  TermsViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 20/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()        
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        if let nav = self.navigationController {
            _ = nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
