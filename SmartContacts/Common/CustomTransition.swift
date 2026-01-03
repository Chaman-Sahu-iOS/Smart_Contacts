//
//  CustomTransition.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 01/04/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.35
    var presenting = true
    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        let width = fromView.frame.size.width
        let centerFrame = CGRect(x: 0, y: 0, width: width, height: fromView.frame.height)
        let completeLeftFrame = CGRect(x: -width, y: 0, width: width, height: fromView.frame.height)
        let completeRightFrame = CGRect(x: +width, y: 0, width: width, height: fromView.frame.height)
        
        containerView.addSubview(toView)
        toView.frame = completeRightFrame
        
        toView.layoutIfNeeded()
        
        if presenting {
        UIView.animate(withDuration: duration,
                        animations: {
                                    fromView.frame = completeLeftFrame
                                    toView.frame   = centerFrame
                         },
                        completion: { _ in
                                    transitionContext.completeTransition(true)
                         }
                     )
        } else {
            
            toView.frame = completeLeftFrame
            
            toView.layoutIfNeeded()
            
            UIView.animate(withDuration: duration,
                           animations: {
                            fromView.frame = completeRightFrame
                            toView.frame   = centerFrame
            },
                           completion: { _ in
                            transitionContext.completeTransition(true)
            }
            )
        }
        
    }
    

}
