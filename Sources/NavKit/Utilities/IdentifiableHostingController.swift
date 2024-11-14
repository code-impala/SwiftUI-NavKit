//
//  IdentifiableHostingController.swift
//  Navigation-package
//
//  Created by Code Impala on 04/11/24.
//

import SwiftUI
import UIKit

class IdentifiableHostingController<Content: View>: UIHostingController<Content> {
    var onDismiss: (() -> Void)?
    private var screenType: String
    
    init(rootView: Content, screenType: String) {
        self.screenType = screenType
        super.init(rootView: rootView)
        
        self.modalPresentationStyle = .pageSheet
        self.isModalInPresentation = false // Allow swipe-to-dismiss
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
