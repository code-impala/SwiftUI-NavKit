//
//  RouteBuilder.swift
//  
//
//  Created by Code Impala on 19/11/24.
//

import SwiftUI

public struct RouteBuilder {
    let routeConfig: RouteConfig
    private var holder: EnvironmentObjectHolder

    public init(routeConfig: RouteConfig) {
        self.routeConfig = routeConfig
        self.holder = EnvironmentObjectHolder()
    }

    public func withEnvironmentObject<Object: ObservableObject>(_ object: Object) -> RouteBuilder {
        let newBuilder = self
        newBuilder.holder.environmentObjects.append(EnvironmentObjectInjector(object))
        return newBuilder
    }
    
    public func generateAppRoute() -> AppRoute {
        let appRoute = AppRoute(routeConfig: routeConfig)
        holder.environmentObjects.forEach { appRoute.withEnvironmentObject($0) }
        return appRoute
    }
}
