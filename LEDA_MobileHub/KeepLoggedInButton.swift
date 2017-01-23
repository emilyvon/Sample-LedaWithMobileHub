//
//  KeepLoggedInButton.swift
//  LEDA
//
//  Created by Mengying Feng on 18/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class KeepLoggedInButton: UIButton {
    
    // Image
    let enabledIcon = UIImage(named: "TickOn")!
    let disabledIcon = UIImage(named: "TickOn_gray")!
    
    // Bool
    var isKeepLoggedInEnabled: Bool = true {
        didSet {
            if isKeepLoggedInEnabled {
                setImage(enabledIcon, for: UIControlState.normal)
                print("Keep user logged in")
                UserDefaults.standard.set(true, forKey: UD_USER_KEEP_LOGGED_IN)
            } else {
                setImage(disabledIcon, for: UIControlState.normal)
                print("Don't keep user logged in")
                UserDefaults.standard.set(false, forKey: UD_USER_KEEP_LOGGED_IN)
            }
        }
    }
    
    override func awakeFromNib() {
        addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isKeepLoggedInEnabled {
                isKeepLoggedInEnabled = false
            } else {
                isKeepLoggedInEnabled = true
            }
            
        }
    }

}
