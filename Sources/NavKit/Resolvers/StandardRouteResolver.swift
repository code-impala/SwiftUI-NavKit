//
//  StandardRouteResolver.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI
import UIKit

public class StandardRouteResolver: RouteResolver {
    private var routeHandler: ((RouteConfig) -> AnyView)?
    
    public init() {}
    
    // Register all routes with a single closure that returns some View
    public func registerRoutes(_ handler: @escaping (RouteConfig) -> AnyView) {
        routeHandler = { route in handler(route) }
    }
    
    // Resolve a view by passing the route to the registered handler and converting to AnyView
    public func resolveView(for route: RouteConfig, environmentObjects: [AnyEnvironmentObject]) -> AnyView? {
        guard let view = routeHandler?(route) else { return nil }
        return injectEnvironmentObjects(view, with: environmentObjects)
    }
    
    // Helper function to inject environment objects into the SwiftUI view
    private func injectEnvironmentObjects(_ view: AnyView, with objects: [AnyEnvironmentObject]) -> AnyView {
        var modifiedView = view
        objects.forEach { injector in
            modifiedView = injector.injectEnvironmentObject(into: modifiedView)
        }
        return modifiedView
    }
}
