//
//  LinkedListNode.swift
//  
//
//  Created by Code Impala on 14/11/24.
//

import Foundation

// MARK: - LinkedListNode
class LinkedListNode<T> {
    var value: T
    var next: LinkedListNode?
    
    init(value: T) {
        self.value = value
    }
}
