//
//  SecureTextEntryButton.swift
//  LEDA
//
//  Created by Mengying Feng on 3/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class SecureTextEntryButton: UIButton {

    // Image
    let showIcon = UIImage(named: "showPassword")!
    let hideIcon = UIImage(named: "hidePassword")!

    // Bool
    var isVisible: Bool = false {
        didSet {
            if isVisible {
                setImage(hideIcon, for: UIControlState.normal)
            } else {
                setImage(showIcon, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isVisible {
                isVisible = false
            } else {
                isVisible = true
            }
        }
    }
    
}
