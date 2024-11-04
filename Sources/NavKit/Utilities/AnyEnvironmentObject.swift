//
//  AnyEnvironmentObject.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI

public protocol AnyEnvironmentObject {
    func injectEnvironmentObject<V: View>(into view: V) -> AnyView
}
