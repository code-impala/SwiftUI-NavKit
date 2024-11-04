//
//  StandardRouteResolver.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI
import UIKit

class StandardRouteResolver: RouteResolver {
    private var routes: [String: ([String: Any]?) -> AnyView] = [:]  // Returns AnyView (SwiftUI View)

    // Register a SwiftUI view with optional parameters
    func registerRoute<V: View>(_ path: String, view: @escaping ([String: Any]?) -> V) {
        routes[path] = { parameters in
            AnyView(view(parameters))  // Wrap the SwiftUI View in AnyView
        }
    }

    // Resolve the view for a given route, with environment object injection
    func resolveView(for path: String, parameters: [String: Any]? = nil, environmentObjects: [AnyEnvironmentObject]) -> AnyView? {
        guard let viewBuilder = routes[path] else { return nil }

        let view = viewBuilder(parameters)

        // Inject environment objects before returning the view
        let injectedView = injectEnvironmentObjects(into: view, with: environmentObjects)

        return injectedView
    }

    // Helper function to inject environment objects into the SwiftUI view
    private func injectEnvironmentObjects<V: View>(into view: V, with objects: [AnyEnvironmentObject]) -> AnyView {
        var modifiedView: AnyView = AnyView(view)

        // Apply each environment object
        objects.forEach { injector in
            modifiedView = injector.injectEnvironmentObject(into: modifiedView)
        }

        return modifiedView
    }
}
