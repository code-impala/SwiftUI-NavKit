//
//  RouterNavigationDelegate.swift
//
//
//  Created by Code Impala on 27/12/24.
//

import UIKit

class RouterNavigationDelegate: NSObject, UINavigationControllerDelegate {
    var animator: RouterNavigationAnimator?

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation.rawValue == 1 {
            animator?.popStyle = true
        } else if operation.rawValue == 2 {
            animator?.popStyle = false
        }
        return animator
    }
}
