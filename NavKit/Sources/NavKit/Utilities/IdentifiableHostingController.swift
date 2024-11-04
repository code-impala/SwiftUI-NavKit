//
//  IdentifiableHostingController.swift
//  Navigation-package
//
//  Created by Code Impala on 04/11/24.
//

import SwiftUI

class IdentifiableHostingController<Content: View>: UIHostingController<Content>, ScreenIdentifiable {
    var screenType: String?
    
    init(rootView: Content, screenType: String?) {
        self.screenType = screenType
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
