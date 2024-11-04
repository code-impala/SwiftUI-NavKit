//
//  Route.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import Foundation

public protocol Route {
    var path: String { get }
    var parameters: [String: Any]? { get }  // Optional parameters
    func withEnvironmentObject(_ object: AnyEnvironmentObject) -> Route
    func withEnvironmentObject<Object: ObservableObject>(_ object: Object) -> Route
    func getEnvironmentObjects() -> [AnyEnvironmentObject]
}
