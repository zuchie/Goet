//
//  Cache.swift
//  Goet
//
//  Created by Zhe Cui on 5/21/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//


struct Cache<T: Hashable, U: Any> {
    private var cache = [T: U]()
    var count: Int { return cache.count }
    var isEmpty: Bool { return cache.isEmpty }
    
    mutating func add(key: T, value: U) {
        cache[key] = value
    }
    
    mutating func remove(key: T) {
        cache[key] = nil
    }
    
    mutating func removeAll(keepingCapacity: Bool) {
        cache.removeAll(keepingCapacity: keepingCapacity)
    }
    
    func get(by key: T) -> U? {
        return cache[key]
    }
}
