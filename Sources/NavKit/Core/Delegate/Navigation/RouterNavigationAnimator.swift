//
//  RouterNavigationAnimator.swift
//  
//
//  Created by Code Impala on 27/12/24.
//

import UIKit

class RouterNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var popStyle: Bool = false

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Customize the animation duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if popStyle {
            animatePop(using: transitionContext)
        } else {
            animatePush(using: transitionContext)
//            animatePop(using: transitionContext)
        }
    }

    private func animatePush(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        let finalFrame = transitionContext.finalFrame(for: toVC)
        let offScreenFrame = finalFrame.offsetBy(dx: finalFrame.width, dy: 0)

        toVC.view.frame = offScreenFrame
        transitionContext.containerView.addSubview(toVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                toVC.view.frame = finalFrame
            },
            completion: { completed in
                transitionContext.completeTransition(completed)
            }
        )
    }

    private func animatePop(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!

        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let offScreenFrame = initialFrame.offsetBy(dx: initialFrame.width, dy: 0)

        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = offScreenFrame
            },
            completion: { completed in
                transitionContext.completeTransition(completed)
            }
        )
    }
}
