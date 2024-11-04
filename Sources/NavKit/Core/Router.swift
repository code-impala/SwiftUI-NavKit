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

    private var navigationController: UINavigationController?
    private var resolver: RouteResolver
    private var environmentObjects: [AnyEnvironmentObject] = []  // Store environment objects for reuse
    public var navigationStack: [String]? {
        activeNavigationController()?.getBackStack()
    }

    // Initialize with a default resolver
    private init(resolver: RouteResolver = StandardRouteResolver()) {
        self.resolver = resolver
    }

    // Allows setting a new resolver
    public func setResolver(_ newResolver: RouteResolver) {
        self.resolver = newResolver
    }

    // Register environment objects that will be applied to all views in this navigation stack
    public func setEnvironmentObjects(_ objects: [AnyEnvironmentObject]) {
        self.environmentObjects = objects
    }

    // Navigate using a Route (inject environment objects automatically)
    public func navigate(to route: Route) {
        guard let view = resolver.resolveView(for: route.path, parameters: route.parameters, environmentObjects: route.getEnvironmentObjects()) else {
            print("Error: No view found for route \(route.path)")
            return
        }

        // Inject stored environment objects
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Push the SwiftUI view with environment objects to the navigation stack
        if navigationController == nil {
            setupRootHostingController(with: viewWithEnvironment, screenType: route.path)
        } else {
            pushHostingController(with: viewWithEnvironment, screenType: route.path)
        }
    }

    // Navigate using a concrete path and optional Codable parameters
    public func navigate<T: Codable>(to path: String, with parameters: T? = nil) {
        if let parameters = parameters {
            // Convert Codable to a dictionary
            guard let paramsDict = try? parameters.asDictionary() else {
                print("Error: Failed to convert parameters to dictionary")
                return
            }
            navigate(to: path, with: paramsDict)
        } else {
            navigate(to: path, with: nil)
        }
    }

    // Navigate using deep link parameters
    public func navigate(to path: String, with parameters: [String: Any]? = nil) {
        guard let view = resolver.resolveView(for: path, parameters: parameters, environmentObjects: []) else {
            print("Error: No view found for route \(path)")
            return
        }

        // Inject stored environment objects
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        if navigationController == nil {
            setupRootHostingController(with: viewWithEnvironment, screenType: path)
        } else {
            pushHostingController(with: viewWithEnvironment, screenType: path)
        }
    }

    // Present modal flow using a Route (with environment objects)
    public func presentModalFlow(to route: Route, animated: Bool = true) {
        guard let view = resolver.resolveView(for: route.path, parameters: route.parameters, environmentObjects: route.getEnvironmentObjects()) else {
            print("Error: No view found for route \(route.path)")
            return
        }

        let viewWithEnvironment = injectEnvironmentObjects(into: view)
        let modalNavigationController = UINavigationController(
            rootViewController: IdentifiableHostingController(rootView: viewWithEnvironment, screenType: route.path)
        )
        activeNavigationController()?.present(modalNavigationController, animated: animated)
    }

    // Present modal flow using deep link parameters
    public func presentModalFlow(to path: String, with parameters: [String: Any]? = nil, animated: Bool = true) {
        guard let view = resolver.resolveView(for: path, parameters: parameters, environmentObjects: []) else {
            print("Error: No view found for route \(path)")
            return
        }

        let viewWithEnvironment = injectEnvironmentObjects(into: view)
        let modalNavigationController = UINavigationController(
            rootViewController: IdentifiableHostingController(rootView: viewWithEnvironment, screenType: path)
        )
        activeNavigationController()?.present(modalNavigationController, animated: animated)
    }

    // Inject stored environment objects into the SwiftUI view
    private func injectEnvironmentObjects<V: View>(into view: V) -> AnyView {
        var modifiedView: AnyView = AnyView(view)

        // Apply each stored environment object
        environmentObjects.forEach { injector in
            modifiedView = injector.injectEnvironmentObject(into: modifiedView)
        }

        return modifiedView
    }

    // Helper function to push a SwiftUI view wrapped in an IdentifiableHostingController to the navigation stack
    private func pushHostingController(with view: some View, screenType: String) {
        let hostingController = IdentifiableHostingController(rootView: AnyView(view), screenType: screenType)
        activeNavigationController()?.pushViewController(hostingController, animated: true)
    }

    // Set up the root hosting controller with environment objects
    private func setupRootHostingController(with rootView: some View, screenType: String) {
        let navigationController = UINavigationController()
        let hostingController = IdentifiableHostingController(rootView: AnyView(rootView), screenType: screenType)
        navigationController.viewControllers = [hostingController]

        self.navigationController = navigationController
        setRootViewController(navigationController)
    }

    // Set up the root window with the provided view and environment objects
    public func setupRootWindow(with windowScene: UIWindowScene, initialRoute: Route) -> UIWindow? {
        let window = UIWindow(windowScene: windowScene)

        // Resolve the initial view using the route
        guard let view = resolver.resolveView(for: initialRoute.path, parameters: initialRoute.parameters, environmentObjects: initialRoute.getEnvironmentObjects()) else {
            print("Error: No view found for route \(initialRoute.path)")
            return nil
        }

        // Inject environment objects into the initial view
        let viewWithEnvironment = injectEnvironmentObjects(into: view)

        // Set up the navigation controller and assign the root view
        let navigationController = UINavigationController()
        let hostingController = IdentifiableHostingController(rootView: viewWithEnvironment, screenType: initialRoute.path)
        navigationController.viewControllers = [hostingController]

        // Assign the window's rootViewController and make it visible
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        // Store the window and navigationController
        self.navigationController = navigationController
        return window
    }
    
    public func navigateBack(steps: Int = 1) {
        activeNavigationController()?.popBack(steps: steps)
    }
    
    public func navigateToRoot() {
        activeNavigationController()?.popToRootViewController(animated: true)
    }
    
    public func navigateBackTo(path: String) {
        activeNavigationController()?.popToScreen(path)
    }
    
    public func navigateBackTo(screen: Route) {
        activeNavigationController()?.popToScreen(screen.path)
    }

    // Set the root window's root view controller
    private func setRootViewController(_ rootViewController: UIViewController) {
        guard let window = UIApplication.shared.getKeyWindow() else {
            print("Error: No window available")
            return
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    // Helper method to get the active UINavigationController
    private func activeNavigationController() -> UINavigationController? {
        var activeNavController = navigationController
        while let presentedController = activeNavController?.presentedViewController as? UINavigationController {
            activeNavController = presentedController
        }
        return activeNavController
    }
}
