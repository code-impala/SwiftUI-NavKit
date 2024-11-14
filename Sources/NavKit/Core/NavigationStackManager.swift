//
//  NavigationStackManager.swift
//  
//
//  Created by Code Impala on 14/11/24.
//

import Foundation
import UIKit

// MARK: - NavigationStackManager
class NavigationStackManager {
    private var mainStackID: UUID
    private var mainNavigationController: UINavigationController
    private var navigationControllers: [UUID: UINavigationController]
    private var activeStackID: UUID
    var stackOrder: LinkedList<UUID>

    init() {
        mainStackID = UUID()
        mainNavigationController = UINavigationController()
        navigationControllers = [mainStackID: mainNavigationController]
        activeStackID = mainStackID
        stackOrder = LinkedList()
        stackOrder.append(mainStackID)
    }
    
    // Main and active stack UUID accessors
    func mainStackUUID() -> UUID { mainStackID }
    func activeStackUUID() -> UUID {
        updateActiveStack()
        return activeStackID
    }

    // Set active stack and update stack order in linked list
    func setActiveStack(_ stackID: UUID) {
        guard navigationControllers[stackID] != nil else {
            print("Error: Stack with ID \(stackID) not found.")
            return
        }
        activeStackID = stackID
        stackOrder.append(stackID) 
    }

    // Create and return a new stack UUID without setting it as active
    func createNavigationStack() -> UUID {
        let stackID = UUID()
        let navigationController = UINavigationController()
        navigationControllers[stackID] = navigationController
        return stackID
    }

    // Retrieve the navigation controller for a stack ID, defaulting to active stack if nil
    func navigationController(for stackID: UUID?) -> UINavigationController? {
        navigationControllers[stackID ?? activeStackUUID()]
    }
    
    // Dismiss stack with cascading dismissal of subsequent modals
    func dismissStack(withID stackID: UUID, animated: Bool = true) {
        guard stackID != mainStackID, let stackToDismiss = navigationControllers[stackID] else {
            print("Error: Cannot dismiss the main stack.")
            return
        }
        
        stackToDismiss.dismiss(animated: animated) {
            self.cleanupStack(from: stackID)
        }
    }

    // Clean up the stack from the dismissed node and onward
    func cleanupStack(from stackID: UUID) {
        // Identify the starting node for cleanup in stackOrder
        guard let startNodeIndex = stackOrder.values().firstIndex(of: stackID) else {
            print("Error: Stack ID not found in stack order.")
            return
        }
        
        // Cascade dismissal for all nodes starting from the specified stackID
        var currentNode = stackOrder.node(at: startNodeIndex)
        while let node = currentNode {
            if let navController = navigationControllers[node.value] {
                navController.dismiss(animated: false) // Dismiss without animation to avoid conflicts
                navigationControllers.removeValue(forKey: node.value)
            }
            currentNode = node.next // Move to the next node
        }
        
        // Remove from stackOrder starting from the given stackID
        stackOrder.remove(from: stackID)
        
        // Update active stack if the removed stack was the active one
        if stackID == activeStackID {
            updateActiveStack()
        }
    }

    // Update active stack based on the topmost navigation controller in the view hierarchy
    private func updateActiveStack() {
        guard let activeNavController = activeNavigationController() else {
            activeStackID = mainStackID
            return
        }
        
        if let activeID = navigationControllers.first(where: { $0.value == activeNavController })?.key {
            activeStackID = activeID
        }
    }

    // Find the active navigation controller in the presentation stack
    private func activeNavigationController() -> UINavigationController? {
        var activeNavController = mainNavigationController
        while let presentedController = activeNavController.presentedViewController as? UINavigationController {
            activeNavController = presentedController
        }
        return activeNavController
    }
}
