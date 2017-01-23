//
//  RatingControl.swift
//  LEDA
//
//  Created by Hao on 24/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class RatingControl: UIView {

    // MARK: Properties
    
    var rating = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var ratingButtons = [UIButton]()
    var spacing = 7
    var stars = 5
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let filledStarImage = UIImage(named: "filledStar")
        let emptyStarImage = UIImage(named: "emptyStar")
        
        for _ in 0..<5 {
            let button = UIButton()
            
            button.setImage(emptyStarImage, for: UIControlState())
            button.setImage(filledStarImage, for: .selected)
            button.setImage(filledStarImage, for: [.highlighted, .selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), for: .touchDown)
            ratingButtons += [button]
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size will fit into the view.
        let frameHeight = Int(frame.size.height)
        let frameWidth = Int(frame.size.width)
        var buttonSize = frameHeight
        let minSpace = 4*spacing + 5*buttonSize
        var offset_x = (frameWidth - minSpace)/2
        var offset_y = 0
        if minSpace > frameWidth {
            buttonSize = (frameWidth - 4*spacing)/5
            offset_x = 0
            offset_y = (frameHeight - buttonSize)/2
        }
//        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing) + offset_x)
            buttonFrame.origin.y = CGFloat(offset_y)
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    
    override var intrinsicContentSize : CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * stars
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func ratingButtonTapped(_ button: UIButton) {
        rating = ratingButtons.index(of: button)! + 1
        updateButtonSelectionStates()
//        self.isUserInteractionEnabled = false
        sendRatedNotification()
    }
    
    func sendRatedNotification() {
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name("RatingControlPressed"),
                object: nil,
                userInfo: ["rating":rating])
    }
    
    
    
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
        
    }

}
