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

    // Set a new route resolver
    public func setResolver(_ newResolver: RouteResolver) {
        self.resolver = newResolver
    }

    // Register environment objects
    public func setEnvironmentObjects(_ objects: [AnyEnvironmentObject]) {
        self.environmentObjects = objects
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
    
    public func setupRootWindow(with windowScene: UIWindowScene, initialRoute: Route) -> UIWindow? {
        let window = UIWindow(windowScene: windowScene)
        
        // Resolve the initial view using the route
        guard let view = resolver.resolveView(for: initialRoute.routeConfig, environmentObjects: initialRoute.getEnvironmentObjects()) else {
            print("Error: No view found for route \(initialRoute.routeConfig.path)")
            return nil
        }
        
        // Inject environment objects into the resolved view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)
        
        // Retrieve the main stack's navigation controller
        guard let mainNavigationController = stackManager.navigationController(for: mainStackUUID()) else {
            print("Error: Main navigation controller not found")
            return nil
        }
        
        // Set the initial view controller for the main stack
        let hostingController = IdentifiableHostingController(rootView: viewWithEnvironment, screenType: initialRoute.routeConfig.path)
        mainNavigationController.viewControllers = [hostingController]
        
        // Set the root view controller of the window and make it visible
        window.rootViewController = mainNavigationController
        window.makeKeyAndVisible()
        
        return window
    }
    
    // Navigate to a route in the specified stack, defaulting to the active stack if no UUID is provided
    public func navigate(to route: Route, inStack stackID: UUID? = nil) {
        // Resolve the view based on the provided route
        guard let view = resolver.resolveView(for: route.routeConfig, environmentObjects: route.getEnvironmentObjects()) else {
            print("Error: No view found for route \(route.routeConfig.path)")
            return
        }

        // Inject environment objects into the resolved view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Retrieve the navigation controller, defaulting to the active stack
        if let navigationController = stackManager.navigationController(for: stackID) {
            pushHostingController(with: viewWithEnvironment, screenType: route.routeConfig.path, in: navigationController)
        } else {
            print("Error: Navigation stack not found")
        }
    }

    public func presentModalFlow(to route: Route, animated: Bool = true) -> UUID? {
        guard let view = resolver.resolveView(for: route.routeConfig, environmentObjects: route.getEnvironmentObjects()) else {
            print("Error: No view found for route \(route.routeConfig.path)")
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
}
