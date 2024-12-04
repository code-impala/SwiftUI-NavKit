//
//  BottomSheetPresentationController.swift
//  
//
//  Created by Code Impala on 04/12/24.
//


import UIKit

class BottomSheetPresentationController: UIPresentationController {
    private let height: CGFloat
    private var dimmingView: UIView!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var presentedViewCornerRadius: CGFloat = 16.0

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat) {
        self.height = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
        setupPanGesture()
    }

    private func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0.0
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet)))
    }

    private func setupPanGesture() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
    }

    @objc private func dismissBottomSheet() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)

        // Apply rounded corners to the presented view
        presentedView?.layer.cornerRadius = presentedViewCornerRadius
        presentedView?.layer.masksToBounds = true

        // Add the pan gesture to the presented view
        presentedView?.addGestureRecognizer(panGestureRecognizer)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}

extension BottomSheetPresentationController: UIGestureRecognizerDelegate {
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else { return }

        let translation = gesture.translation(in: presentedView)
        let velocity = gesture.velocity(in: presentedView)

        switch gesture.state {
        case .changed:
            // Drag the view down
            if translation.y > 0 {
                presentedView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            // Check if the velocity or position exceeds the threshold for dismissal
            let shouldDismiss = translation.y > presentedView.frame.height / 3 || velocity.y > 1000
            if shouldDismiss {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                // Snap back to the original position
                UIView.animate(withDuration: 0.3) {
                    presentedView.transform = .identity
                }
            }
        default:
            break
        }
    }
}
