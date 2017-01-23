//
//  VideoPlayerSlider.swift
//  LEDA
//
//  Created by Mengying Feng on 12/12/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class VideoPlayerSlider: UISlider {

    override func draw(_ rect: CGRect) {
        
        super.awakeFromNib()
        
        setThumbImage(UIImage(named: "sliderThumb")!, for: UIControlState.normal)
        thumbRect(forBounds: CGRect(x: 0, y: 0, width: 8, height: 8), trackRect: CGRect(x: 0, y: 0, width: 50, height: 50), value: 10)
        minimumTrackTintColor = UIColor(red: 100/255, green: 203/255, blue: 236/255, alpha: 1.0)
        maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
    }
    
    
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 10, width: bounds.size.width , height: 6.0)
    }

}
