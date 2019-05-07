//
//  BLCacheStorage.swift
//  BLCache
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

class BLCacheStorage <Key: Hashable, Value: Any> {
    private var dictStorage = Dictionary<Key, Value>()
    private let queue = DispatchQueue(label: "com.bl.cache", qos: DispatchQoS.userInitiated, attributes: .concurrent)

    internal func set(value val: Value, forKey key: Key, size sizeInBytes: UInt) {
        write { [weak self] in
            guard let weakself = self else {
                return
            }
            weakself.dictStorage[key] = val
        }
    }
    
    internal func getValue(forKey key: Key) -> Value? {
        var ret : Value?
        queue.sync {
            ret = self.dictStorage[key]
        }
        return ret
    }
    
    private func write(block: @escaping ()->()) {
        queue.async (flags: .barrier){
            block()
        }
    }
}
