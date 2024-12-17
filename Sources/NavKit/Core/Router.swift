//
//  Router.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI
import UIKit

public class Router {
    public static let shared = Router()
    private var stackManager = NavigationStackManager()
    private var resolver: RouteResolver
    private var environmentObjects: [AnyEnvironmentObject] = []
    
    public var stackOrder: [UUID] {
        stackManager.stackOrder.values()
    }

    // Initialize with a default resolver
    private init(resolver: RouteResolver = StandardRouteResolver()) {
        self.resolver = resolver
    }
    
    public func addEnvironmentObject(_ injector: AnyEnvironmentObject) {
           addEnvironmentObjects([injector])
       }
    
    private func addEnvironmentObjects(_ objects: [AnyEnvironmentObject]) {
        for newObject in objects {
            // Check if an object of the same type exists in the list
            if let index = environmentObjects.firstIndex(where: { $0.wrappedType == newObject.wrappedType }) {
                // Replace the existing object
                environmentObjects[index] = newObject
            } else {
                // Add the new object if it doesn't exist
                environmentObjects.append(newObject)
            }
        }
    }

    // Set a new route resolver
    public func setResolver(_ newResolver: RouteResolver) {
        self.resolver = newResolver
    }


    // Return the main stack UUID for reference
    public func mainStackUUID() -> UUID {
        return stackManager.mainStackUUID()
    }

    // Return the active stack UUID for reference
    public func activeStackUUID() -> UUID {
        return stackManager.activeStackUUID()
    }

    // Set the active stack by UUID
    public func setActiveStack(_ stackID: UUID) {
        stackManager.setActiveStack(stackID)
    }

    // Create a new stack and return its UUID without setting it active
    public func createNavigationStack() -> UUID {
        return stackManager.createNavigationStack()
    }
    
    public func getEnvironmentObjects() -> [AnyEnvironmentObject] {
          return environmentObjects
      }
    
    @discardableResult
    public func setupRootWindow(with window: UIWindow, initialRoute: AppRoute) -> UINavigationController? {
            // Synchronize environment objects from the route into the Router
            let routeEnvironmentObjects = initialRoute.getEnvironmentObjects()
            self.addEnvironmentObjects(routeEnvironmentObjects)

            // Resolve the initial view using the route
            guard let view = resolver.resolveView(for: initialRoute.routeConfig) else {
                print("Error: No view found for route \(initialRoute.routeConfig.path)")
                return nil
            }

            // Inject environment objects into the resolved view
            let viewWithEnvironment = injectEnvironmentObjects(into: view)

            guard let mainNavigationController = stackManager.navigationController(for: mainStackUUID()) else {
                print("Error: Main navigation controller not found")
                return nil
            }

            let hostingController = IdentifiableHostingController(rootView: viewWithEnvironment, screenType: initialRoute.routeConfig.path)
            mainNavigationController.viewControllers = [hostingController]

            window.rootViewController = mainNavigationController
            window.makeKeyAndVisible()
            return mainNavigationController
        }
    
    // Navigate to a route in the specified stack, defaulting to the active stack if no UUID is provided
    public func navigate(to route: Route, inStack stackID: UUID? = nil, clearBackStack: Bool = false) {
        let routeEnvironmentObjects = route.getEnvironmentObjects()
        self.addEnvironmentObjects(routeEnvironmentObjects)
        // Resolve the view based on the provided route
        guard let view = resolver.resolveView(for: route.routeConfig) else {
            print("Error: No view found for route \(route.routeConfig.path)")
            return
        }

        // Inject environment objects into the resolved view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Retrieve the navigation controller, defaulting to the active stack
        if let navigationController = stackManager.navigationController(for: stackID) {
            if clearBackStack {
                // Clear the back stack and set the new view as the root
                setHostingControllerAsRoot(with: viewWithEnvironment, screenType: route.routeConfig.path, in: navigationController)
            } else {
                // Push the new view onto the existing navigation stack
                pushHostingController(with: viewWithEnvironment, screenType: route.routeConfig.path, in: navigationController)
            }
        } else {
            print("Error: Navigation stack not found")
        }
    }
    
    public func dismissFullScreenCover(withID stackID: UUID? = nil, animated: Bool = true) {
        // Get the stack ID to dismiss, defaulting to the active stack
        let targetStackID = stackID ?? stackManager.activeStackUUID()

        // Retrieve the navigation controller for the stack
        guard let navigationController = stackManager.navigationController(for: targetStackID) else {
            print("Error: Full-screen cover stack not found.")
            return
        }

        // Ensure the navigation controller being dismissed was presented as a full-screen cover
        guard navigationController.modalPresentationStyle == .overCurrentContext ||
              navigationController.modalPresentationStyle == .fullScreen else {
            print("Error: The stack is not a full-screen cover.")
            return
        }

        // Dismiss the full-screen cover
        navigationController.dismiss(animated: animated) {
            self.stackManager.cleanupStack(from: targetStackID)
            print("Full-screen cover dismissed for stack ID: \(targetStackID)")
        }
    }

    
    private func setHostingControllerAsRoot(with view: some View, screenType: String, in navigationController: UINavigationController) {
        let hostingController = IdentifiableHostingController(rootView: AnyView(view), screenType: screenType)
        navigationController.setViewControllers([hostingController], animated: false) // Clear back stack by setting only one view
    }

    @discardableResult
    public func presentModalFlow(to route: Route, animated: Bool = true, onDismiss: (() -> Void)? = nil) -> UUID? {
        guard let view = resolver.resolveView(for: route.routeConfig) else {
            print("Error: No view found for route3 \(route.routeConfig.path)")
            return nil
        }

        let viewWithEnvironment = injectEnvironmentObjects(into: view)
        let modalStackID = stackManager.createNavigationStack()

        guard let modalNavigationController = stackManager.navigationController(for: modalStackID) else {
            print("Error: Failed to create modal navigation controller.")
            return nil
        }

        // Set up the hosting controller with a dismiss handler
        let hostingController = IdentifiableHostingController(rootView: viewWithEnvironment, screenType: route.routeConfig.path)
        hostingController.onDismiss = { [weak self] in
            self?.stackManager.cleanupStack(from: modalStackID)
            onDismiss?()
            print("Modal dismissed for stack ID: \(modalStackID)")
        }

        modalNavigationController.viewControllers = [hostingController]

        // Set the presentationController delegate on modalNavigationController
        modalNavigationController.presentationController?.delegate = modalNavigationController

        // Present the modal from the active stack or fallback to the main stack
        guard let presentingController = stackManager.navigationController(for: nil) ?? stackManager.navigationController(for: stackManager.mainStackUUID()) else {
            print("Error: No active navigation controller found for presenting.")
            return nil
        }

        presentingController.present(modalNavigationController, animated: animated) {
            self.stackManager.setActiveStack(modalStackID)
        }
        
        return modalStackID
    }
    
    @discardableResult
    public func presentFullScreenCover(to route: Route, animated: Bool = true, onDismiss: (() -> Void)? = nil) -> UUID? {
        // Resolve the view based on the provided route
        guard let view = resolver.resolveView(for: route.routeConfig) else {
            print("Error: No view found for route \(route.routeConfig.path)")
            return nil
        }

        // Inject environment objects into the resolved view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Create a new navigation stack for the full-screen cover
        let fullScreenStackID = stackManager.createNavigationStack()

        guard let fullScreenNavigationController = stackManager.navigationController(for: fullScreenStackID) else {
            print("Error: Failed to create navigation controller for full-screen cover.")
            return nil
        }

        // Set up the hosting controller for the full-screen view
        let hostingController = IdentifiableHostingController(rootView: viewWithEnvironment, screenType: route.routeConfig.path)
        
        hostingController.onDismiss = { [weak self] in
            self?.stackManager.cleanupStack(from: fullScreenStackID)
            onDismiss?()
            print("Fullscreen dismissed for stack ID: \(fullScreenStackID)")
        }

        // Add the hosting controller to the navigation stack
        fullScreenNavigationController.viewControllers = [hostingController]

        // Set the modal presentation style for the navigation controller
        fullScreenNavigationController.modalPresentationStyle = .overCurrentContext

        // Present the navigation controller as a full-screen cover
        guard let presentingController = UIApplication.shared.windows.first?.rootViewController else {
            print("Error: No root view controller found.")
            return nil
        }

        presentingController.present(fullScreenNavigationController, animated: animated) {
            self.stackManager.setActiveStack(fullScreenStackID)
        }

        return fullScreenStackID
    }
    
    public func presentBottomSheet(to route: Route, inStack stackID: UUID? = nil) {
        // Resolve the view based on the provided route
        guard let view = resolver.resolveView(for: route.routeConfig) else {
            print("Error: No view found for route \(route.routeConfig.path)")
            return
        }

        // Inject environment objects into the resolved view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Wrap the resolved view in a custom bottom sheet
        let hostingController = UIHostingController(rootView: viewWithEnvironment)

        // Present the bottom sheet
        guard let presentingController = stackManager.navigationController(for: stackID) ??
                                          stackManager.navigationController(for: stackManager.mainStackUUID()) ??
                                          UIApplication.shared.windows.first?.rootViewController else {
            print("Error: No active navigation controller or root view controller found.")
            return
        }
        configureCustomBottomSheet(for: hostingController, in: presentingController)
    }



    // Pop view controllers in the specified stack, defaulting to the active stack if no UUID is provided
    public func pop(inStack stackID: UUID? = nil, steps: Int = 1, animated: Bool = true) {
        // Retrieve the navigation controller for the specified or active stack
        guard let navigationController = stackManager.navigationController(for: stackID) else {
            print("Error: Navigation stack not found")
            return
        }
        
        let totalViewControllers = navigationController.viewControllers.count
        let targetIndex = totalViewControllers - steps - 1
        
        // Ensure target index is within bounds
        guard targetIndex >= 0 else {
            print("Error: Not enough view controllers in the stack to pop \(steps) steps.")
            return
        }
        
        let targetViewController = navigationController.viewControllers[targetIndex]
        navigationController.popToViewController(targetViewController, animated: animated)
    }
    
    public func popToRoot(inStack stackID: UUID? = nil, animated: Bool = true) {
        guard let navigationController = stackManager.navigationController(for: stackID) else {
            print("Error: Navigation stack not found")
            return
        }
        navigationController.popToRootViewController(animated: animated)
    }
    
    public func popToViewController(ofType type: UIViewController.Type, inStack stackID: UUID? = nil, animated: Bool = true) {
        guard let navigationController = stackManager.navigationController(for: stackID) else {
            print("Error: Navigation stack not found")
            return
        }
        
        if let targetViewController = navigationController.viewControllers.first(where: { $0.isKind(of: type) }) {
            navigationController.popToViewController(targetViewController, animated: animated)
        } else {
            print("Error: No view controller of type \(type) found in the stack.")
        }
    }
    
    // Dismiss a modal stack by its UUID, and reset active stack if needed
    public func dismissModalStack(withID stackID: UUID? = nil, animated: Bool = true) {
        stackManager.dismissStack(withID: stackID ?? stackManager.activeStackUUID(), animated: animated)
    }

    // Inject environment objects into the SwiftUI view
    private func injectEnvironmentObjects<V: View>(into view: V) -> AnyView {
        var modifiedView: AnyView = AnyView(view)
        environmentObjects.forEach { injector in
            modifiedView = injector.injectEnvironmentObject(into: modifiedView)
        }
        return modifiedView
    }

    // Push view controller onto the specified navigation controller
    private func pushHostingController(with view: some View, screenType: String, in navigationController: UINavigationController) {
        let hostingController = IdentifiableHostingController(rootView: AnyView(view), screenType: screenType)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    private func configureCustomBottomSheet(for hostingController: UIHostingController<AnyView>, in presentingController: UIViewController, height: CGFloat = UIScreen.main.bounds.height * 0.5) {
        let transitioningDelegate = BottomSheetTransitioningDelegate(height: height)
        hostingController.modalPresentationStyle = .custom
        hostingController.transitioningDelegate = transitioningDelegate

        presentingController.present(hostingController, animated: true, completion: nil)
    }
}
