//
//  LinkedList.swift
//  iOS
//
//  Created by Sergey Petrov on 4/16/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation

private class LinkedListNode<T> {
    var value: T
    var next: LinkedListNode?
    weak var prev: LinkedListNode?

    public init(value: T) {
        self.value = value
    }
}

public class LinkedList<T> {
  
    private typealias Node = LinkedListNode<T>

    private var head: Node?
    
    private weak var tail: Node?
    
    public var isEmpty: Bool {
        return head == nil
    }

    public var first: T? {
        return head?.value
    }
    
    public var last: T? {
        return tail?.value
    }
    
    public func append(_ value: T) {
        let newNode = Node(value: value)
        if let tail = tail {
            newNode.prev = tail
            tail.next = newNode
            self.tail = newNode
        } else {
            head = newNode
            tail = newNode
        }
    }
    
    public func appendAll(_ array: [T]) {
        for element in array {
            append(element)
        }
    }
    
    public func removeFirst() -> T? {
        if let head = head {
            self.head = head.next
            self.head?.prev = nil
            return head.value
        }
        return nil
    }
    
    public func removeLast() -> T? {
        if let tail = tail {
            self.tail = tail.prev
            self.tail?.next = nil
            return tail.value
        }
        return nil
    }
    
    public func removeAll() {
        head = nil
        tail = nil
    }
}
