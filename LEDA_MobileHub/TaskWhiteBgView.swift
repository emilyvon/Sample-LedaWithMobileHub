//
//  TaskWhiteBgView.swift
//  LEDA
//
//  Created by Mengying Feng on 31/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//


import UIKit


class TaskWhiteBgView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 4
        
    }

}
