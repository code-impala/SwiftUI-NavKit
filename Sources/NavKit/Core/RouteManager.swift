//
//  Encodable+Extensions.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import UIKit

public class RouteManager {
    // Dictionary to store route paths and their corresponding view controller factories
    private var routes: [String: () -> UIViewController] = [:]

    // Public initializer
    public init() {}

    // Method to add a route
    public func addRoute(_ path: String, viewController: @escaping () -> UIViewController) {
        routes[path] = viewController
    }

    // Method to retrieve a view controller for a given path
    public func viewController(for path: String) -> UIViewController? {
        return routes[path]?()
    }

    // Method to clear all routes (useful if you need to reset routes in certain cases)
    public func clearRoutes() {
        routes.removeAll()
    }
}

