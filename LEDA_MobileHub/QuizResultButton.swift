//
//  QuizResultButton.swift
//  LEDA
//
//  Created by Mengying Feng on 17/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class QuizResultButton: UIButton {
    
    var isChecked: Bool = false {
        didSet {
            //            if isChecked {
            //                self.setTitleColor(COLOR_LIGHT_BLUE, for: .normal)
            //            } else {
            //                self.setTitleColor(UIColor.gray, for: .normal)
            //            }
        }
    }
    
    override func awakeFromNib() {
        
        whiteBgUI()
        
        addTarget(self, action: #selector(buttonTouchUpOutside(sender:)), for: .touchUpOutside)
        addTarget(self, action: #selector(buttonTouchDown(sender:)), for: UIControlEvents.touchDown)
        addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    func buttonTouchDown(sender: UIButton) {
        
        if sender == self {
            blueBgUI()
        }
    }
    
    func buttonTouchUpInside(sender: UIButton) {
        
        whiteBgUI()
        
        if sender == self {
            if isChecked {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
    
    func buttonTouchUpOutside(sender: UIButton) {
        if sender == self {
            whiteBgUI()
        }
    }
    
    func whiteBgUI() {
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = UIColor.white
        setTitleColor(UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0), for: .normal)
    }
    
    func blueBgUI() {
        layer.borderWidth = 0
        backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
        setTitleColor(UIColor.white, for: UIControlState.highlighted)
        setTitleColor(UIColor.white, for: .normal)
    }
}
