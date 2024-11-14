//
//  AppRoute.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import Foundation

public class AppRoute: Route {
    private var environmentObjects: [AnyEnvironmentObject] = []
    public let routeConfig: any RouteConfig
    
    // Initialize with any developer-defined RouteConfig
    public init(routeConfig: RouteConfig) {
        self.routeConfig = routeConfig
    }
    
    // Path of the route, sourced from the developer's RouteConfig
    public var path: String {
        return routeConfig.path
    }
    
    // Add an environment object to this route instance (accepts AnyEnvironmentObject)
    @discardableResult
    public func withEnvironmentObject(_ object: AnyEnvironmentObject) -> Route {
        self.environmentObjects.append(object)
        return self
    }
    
    @discardableResult
    public func withEnvironmentObject<Object>(_ object: Object) -> any Route where Object : ObservableObject {
        self.environmentObjects.append(EnvironmentObjectInjector(object))
        return self
    }
    
    // Retrieve the environment objects for this instance
    public func getEnvironmentObjects() -> [AnyEnvironmentObject] {
        return environmentObjects
    }
}
