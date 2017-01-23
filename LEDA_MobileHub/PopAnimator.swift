//
//  PopAnimator.swift
//  LEDA
//
//  Created by Mengying Feng on 11/1/17.
//  Copyright © 2017 Andrew Osborne. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.2
    var presenting  = true
    var originFrame = CGRect.zero
    var isExpanding = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)-> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let herbView = presenting ? toView : transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        if isExpanding {
            herbView.alpha = 0
        } else {
            herbView.alpha = 1
        }
        
        let initialFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            herbView.transform = scaleTransform
            herbView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            herbView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView)
        
        UIView.animate(withDuration: duration, delay:0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: [.curveLinear],
                       animations: {
                        herbView.transform = self.presenting ?
                            CGAffineTransform.identity : scaleTransform
                        
                        
                        herbView.center = CGPoint(x: finalFrame.midX,
                                                  y: finalFrame.midY)
                        
                        if self.isExpanding {
                            herbView.alpha = 1
                        } else {
                            herbView.alpha = 0
                        }
                        
        }, completion:{_ in
            self.isExpanding = false
            transitionContext.completeTransition(true)
        })
        
    }
    
}
