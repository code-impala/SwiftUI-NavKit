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
    
    // Property to hold the key for associated objects
    private var environmentObjectKey: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: "environmentObjectHolderKey".hashValue)!
    }
    
    // Computed property that retrieves or sets the EnvironmentObjectHolder using associated objects
    private var holder: EnvironmentObjectHolder {
        if let holder = objc_getAssociatedObject(self, environmentObjectKey) as? EnvironmentObjectHolder {
            return holder
        } else {
            let newHolder = EnvironmentObjectHolder()
            objc_setAssociatedObject(self, environmentObjectKey, newHolder, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHolder
        }
    }
    
    // Method to add an environment object to the temporary storage
    func withEnvironmentObject<Object: ObservableObject>(_ object: Object) -> Self {
        holder.environmentObjects.append(EnvironmentObjectInjector(object))
        return self
    }

    // Method to generate the final AppRoute, injecting the stored environment objects
    func generateRoute() -> AppRoute {
        let appRoute = AppRoute(routeConfig: self)
        holder.environmentObjects.forEach { appRoute.withEnvironmentObject($0) }
        return appRoute
    }
}
