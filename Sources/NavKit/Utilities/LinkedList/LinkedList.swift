//
//  LinkedList.swift
//  
//
//  Created by Code Impala on 14/11/24.
//

import Foundation

// MARK: - LinkedList
class LinkedList<T: Equatable> {
    private var head: LinkedListNode<T>?
    
    func count() -> Int {
        var current = head
        var count = 0
        
        while current != nil {
            count += 1
            current = current?.next
        }
        
        return count
    }
    
    // Remove a node with the given value and all following nodes
    func remove(from value: T) {
        guard let head = head else { return }
        
        // If the head matches, clear the list
        if head.value == value {
            self.head = nil
            return
        }
        
        // Traverse to find the node with `value` and remove it along with all successors
        var current: LinkedListNode<T>? = head
        while let next = current?.next {
            if next.value == value {
                current?.next = nil  // Cut off the linked list at the found node
                return
            }
            current = next
        }
    }
    
    // Append a new node at the end of the linked list
    func append(_ value: T) {
        let newNode = LinkedListNode(value: value)
        
        // Check if value already exists in the list (for debugging)
        if contains(value) {
            fatalError("Warning: Attempting to add duplicate value \(value) to the linked list.")
        }
        
        guard let head = head else {
            self.head = newNode
            return
        }
        
        var current = head
        while let next = current.next {
            current = next
        }
        
        current.next = newNode
    }
    
    // Helper function to check if a value exists in the list
    func contains(_ value: T) -> Bool {
        var current = head
        while let node = current {
            if node.value == value {
                return true
            }
            current = node.next
        }
        return false
    }
    
    // Retrieve all values in the linked list
    func values() -> [T] {
        var values = [T]()
        var current = head
        while let node = current {
            values.append(node.value)
            print("debug --> \(values)")
            current = node.next
        }
        return values
    }
    
    // Retrieve the node at the specified index
    func node(at index: Int) -> LinkedListNode<T>? {
        guard index >= 0 else { return nil }
        
        var current = head
        var currentIndex = 0
        
        while let node = current {
            if currentIndex == index {
                return node
            }
            current = node.next
            currentIndex += 1
        }
        
        return nil // Return nil if the index is out of bounds
    }
}
