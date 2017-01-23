//
//  Marker3View.swift
//  testing-drawing
//
//  Created by Mengying Feng on 2/11/16.
//  Copyright © 2016 iEmRollin. All rights reserved.
//

import UIKit

class Marker3View: UIView {

    private var _number: CGFloat = 100.0
    var number: CGFloat {
        set (new) {
            if new < 0 {
                _number = 0
            }
            else if new > 300 {
                _number = 300
            }
            else {
                _number = new
            }
            setNeedsDisplay()
        }
        get {
            return _number
        }
    }
    
    private var _frameSize: CGRect = CGRect(x: 0, y: 0, width: 300, height: 165)
    var frameSize: CGRect {
        set (new) {
            _frameSize = new
            setNeedsDisplay()
        }
        get {
            return _frameSize
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        Marker3.drawCanvas1(outerFrame: frameSize, markerPos: number*3, resultTxt: "\(Int(number))")
    }
 

}
