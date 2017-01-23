//
//  PrivacyViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 20/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backBtnPressed(_ sender: UIButton) {
        
        if let nav = self.navigationController {
            _ = nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
//        _ = self.navigationController?.popViewController(animated: true)
        
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    

}
