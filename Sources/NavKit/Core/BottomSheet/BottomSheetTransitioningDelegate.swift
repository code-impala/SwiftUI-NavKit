//
//  BottomSheetTransitioningDelegate.swift
//
//
//  Created by Code Impala on 04/12/24.
//

import UIKit

public class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let height: CGFloat

    init(height: CGFloat) {
        self.height = height
        super.init()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting, height: height)
    }
}
