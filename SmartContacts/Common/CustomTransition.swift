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

        // Safely obtain view controllers and views
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        guard let fromView = (transitionContext.view(forKey: .from) ?? fromVC.view),
              let toView = (transitionContext.view(forKey: .to) ?? toVC.view) else {
            transitionContext.completeTransition(false)
            return
        }

        // Use container bounds for consistent, full-screen frames
        let baseFrame = containerView.bounds
        let width = baseFrame.size.width
        let height = baseFrame.size.height

        let centerFrame = baseFrame
        let completeLeftFrame = CGRect(x: baseFrame.minX - width, y: baseFrame.minY, width: width, height: height)
        let completeRightFrame = CGRect(x: baseFrame.minX + width, y: baseFrame.minY, width: width, height: height)

        if presenting {
            toView.frame = completeRightFrame
            containerView.addSubview(toView)

            UIView.animate(withDuration: duration,
                           animations: {
                            fromView.frame = completeLeftFrame
                            toView.frame   = centerFrame
                           },
                           completion: { _ in
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        } else {
            // Insert destination beneath the source when dismissing
            toView.frame = completeLeftFrame
            containerView.insertSubview(toView, belowSubview: fromView)

            UIView.animate(withDuration: duration,
                           animations: {
                            fromView.frame = completeRightFrame
                            toView.frame   = centerFrame
                           },
                           completion: { _ in
                            // Remove the dismissed view to prevent overlay/black screens
                            if !transitionContext.transitionWasCancelled {
                                fromView.removeFromSuperview()
                            }
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                           })
        }

    }
    

}
