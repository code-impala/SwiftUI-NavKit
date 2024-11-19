//
//  StandardRouteResolver.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI
import UIKit

public class StandardRouteResolver: RouteResolver {
    private var routeHandlers: [RouteHandler] = []
    
    public init() {}
    
    // Register route handlers for different modules
    public func registerRouteHandler(_ handler: RouteHandler) {
        routeHandlers.append(handler)
    }
    
    // Resolve the view by delegating to registered handlers
    public func resolveView(for route: RouteConfig) -> AnyView? {
        for handler in routeHandlers {
            if let view = handler.resolveView(for: route) {
                return view
            }
        }
        return nil // No handler found for the route
    }
    
    // Inject environment objects into the view
    private func injectEnvironmentObjects(_ view: AnyView, with objects: [AnyEnvironmentObject]) -> AnyView {
        var modifiedView = view
        objects.forEach { injector in
            modifiedView = injector.injectEnvironmentObject(into: modifiedView)
        }
        return modifiedView
    }
}
