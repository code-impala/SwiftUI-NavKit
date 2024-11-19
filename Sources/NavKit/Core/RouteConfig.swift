//
//  RouteConfig.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import Foundation
import ObjectiveC

public protocol RouteConfig {
    var path: String { get }
}

public extension RouteConfig {
    public func generateRouteBuilder() -> RouteBuilder {
        let builder = RouteBuilder(routeConfig: self)
        return builder
    }
    
    public func generateRoute() -> AppRoute {
        let builder = self.generateRouteBuilder()
        let route = builder.generateAppRoute()
        return route
    }
}
