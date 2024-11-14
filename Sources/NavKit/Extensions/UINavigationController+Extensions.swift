//
//  UINavigationController+Extensions.swift
//  Navigation-package
//
//  Created by Code Impala on 04/11/24.
//

import SwiftUI
import UIKit

extension UINavigationController {
    
    func getBackStack() -> [String] {
        return viewControllers.compactMap { ($0 as? ScreenIdentifiable)?.screenType }
    }
    
    // Pop to a specific screen in the navigation stack based on the screen's identifier
    func popToScreen(_ screenType: String, animated: Bool = true) {
        if let targetViewController = viewControllers.first(where: { ($0 as? ScreenIdentifiable)?.screenType == screenType }) {
            popToViewController(targetViewController, animated: animated)
        } else {
            popBack()
            print("Error: Screen \(screenType) not found in the navigation stack.")
        }
    }
    
    // Pop back by a specified number of steps in the navigation stack
    func popBack(steps: Int = 1, animated: Bool = true) {
        let totalViewControllers = viewControllers.count
        let targetIndex = totalViewControllers - steps - 1
        
        // Check if the target index is within bounds
        guard targetIndex >= 0 else {
            print("Error: Unable to navigate back \(steps) steps. Not enough view controllers in the stack.")
            return
        }
        
        let targetViewController = viewControllers[targetIndex]
        popToViewController(targetViewController, animated: animated)
    }
}

extension UINavigationController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let hostingController = viewControllers.first as? IdentifiableHostingController<AnyView> {
            hostingController.onDismiss?()
            print("Dismissal detected in UINavigationController")
        }
    }
}
