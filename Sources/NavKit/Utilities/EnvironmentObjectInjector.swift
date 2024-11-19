//
//  EnvironmentObjectInjector.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import SwiftUI

 class EnvironmentObjectInjector<Object: ObservableObject>: AnyEnvironmentObject {
    let object: Object

     init(_ object: Object) {
        self.object = object
    }

     func injectEnvironmentObject<V: View>(into view: V) -> AnyView {
        return AnyView(view.environmentObject(object))
    }

     var wrappedType: Any.Type {
        return Object.self
    }
}
