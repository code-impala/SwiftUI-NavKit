//
//  RouteHandler.swift
//  
//
//  Created by Code Impala on 19/11/24.
//

import Foundation
import SwiftUI

public protocol RouteHandler {
    func resolveView(for route: RouteConfig) -> AnyView?
}
