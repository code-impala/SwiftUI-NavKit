//
//  UIApplication+Extensions.swift
//  Navigation-package
//
//  Created by Code Impala on 20/10/24.
//

import UIKit

extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        // Iterate through all scenes
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }    // Get all window scenes
            .flatMap { $0.windows }                 // Get the windows for each scene
            .first { $0.isKeyWindow }               // Return the key window
    }
}
