//
//  TaskBackgroundOutlineView.swift
//  LEDA
//
//  Created by Mengying Feng on 16/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class TaskBackgroundOutlineView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 4
    }
    

}
