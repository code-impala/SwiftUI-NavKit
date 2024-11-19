//
//  RouteResolver.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI

public protocol RouteResolver {
    // This method resolves the view controller for a given path
    func resolveView(for route: RouteConfig) -> AnyView?
}
