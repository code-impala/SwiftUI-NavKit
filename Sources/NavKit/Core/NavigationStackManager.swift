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
    var navigationControllers: [UUID: UINavigationController] {
        didSet {
            syncStackOrder()
            if !navigationControllers.keys.contains(activeStackID) {
                updateActiveStack()
            }
        }
    }
    private(set) var activeStackID: UUID
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
    
    func getNavigationController(stackId: UUID) -> UINavigationController? {
        return navigationControllers[stackId]
    }

    // Set active stack and update stack order in linked list
    func setActiveStack(_ stackID: UUID) {
        guard navigationControllers[stackID] != nil else {
            print("Error: Stack with ID \(stackID) not found.")
            return
        }
        activeStackID = stackID
        if !stackOrder.contains(stackID) {
            stackOrder.append(stackID)
        }
    }
    
    func addController(stackId: UUID, controller: UINavigationController) {
        navigationControllers[stackId] = controller
    }

    // Create and return a new stack UUID without setting it as active
    func createNavigationStack() -> UUID {
        let stackID = UUID()
        let navigationController = UINavigationController()
        navigationControllers[stackID] = navigationController
        print("debug --> stack created --> \(stackID)")
        return stackID
    }

    // Retrieve the navigation controller for a stack ID, defaulting to active stack if nil
    func navigationController(for stackID: UUID?) -> UINavigationController? {
        navigationControllers[stackID ?? activeStackUUID()]
    }

    // Sync the stackOrder with navigationControllers
    private func syncStackOrder() {
        let currentKeys = Set(navigationControllers.keys)
        var node = stackOrder.node(at: 0)

        // Remove nodes from stackOrder that no longer exist in navigationControllers
        while let currentNode = node {
            if !currentKeys.contains(currentNode.value) {
                stackOrder.remove(from: currentNode.value)
            }
            node = currentNode.next
        }

        // Add missing keys from navigationControllers to stackOrder
        for key in navigationControllers.keys where !stackOrder.contains(key) {
            stackOrder.append(key)
        }
    }

    func removeStack(withID stackID: UUID) {
        navigationControllers.removeValue(forKey: stackID)
        print("Stack with ID \(stackID) has been removed.")
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
