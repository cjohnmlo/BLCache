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

    private let accessMapQueue = DispatchQueue(label: "com.bl.accessCountQueue", qos: DispatchQoS.userInitiated)
    private var accessCountMap = Dictionary<Key, UInt>()
    private var currentStorage = UInt(0.byte)
    private var sizeMap = Dictionary<Key,UInt>()
    
    private var limit = UInt(5.megabyte)
    
    init(limit: UInt) {
        // set floor and ceiling
        if limit < 1.megabyte {
            self.limit = UInt(1.megabyte)
        }
        else if limit > 100.megabyte {
            self.limit = UInt(1.megabyte)
        }
        else {
            self.limit = limit
        }
    }
    
    internal func set(value val: Value, forKey key: Key, size sizeInBytes: UInt) {
        write { [weak self] in
            guard let weakself = self else {
                return
            }
            
            guard sizeInBytes <= weakself.limit else {
                return
            }
            
            if weakself.limit - weakself.currentStorage < sizeInBytes {
                let requiredSpace = sizeInBytes - (weakself.limit - weakself.currentStorage)
                let deletedSpace = weakself.makeSpace(size: requiredSpace, forKey: key)
                if deletedSpace < requiredSpace {
                    return
                }
                weakself.currentStorage = weakself.currentStorage - deletedSpace
            }
            
            weakself.currentStorage = weakself.currentStorage + sizeInBytes
            weakself.dictStorage[key] = val
            weakself.sizeMap[key] = sizeInBytes
        }
    }
    
    private func makeSpace(size: UInt, forKey: Key) -> UInt {
        var deletedSize : UInt = 0
        var accessCopy : Dictionary<Key, UInt>?
        accessMapQueue.sync {
            accessCopy = self.accessCountMap
        }
        while deletedSize < size {
            
            let leastAccessed = accessCopy?.min { (a, b) -> Bool in
                a.value < b.value
            }
            
            guard let leastAccess = leastAccessed else {
                return deletedSize
            }
            
            if leastAccess.key == forKey {
                // ignore it, this the new element for key
                accessCopy?[forKey] = nil
                continue
            }
            
            
            if dictStorage[leastAccess.key] != nil {
                deletedSize = deletedSize + self.sizeMap[leastAccess.key]!
            }
            
            self.dictStorage[leastAccess.key] = nil
            self.sizeMap[leastAccess.key] = nil
            accessCopy?[leastAccess.key] = nil
        }
        
        return deletedSize
    }
    
    internal func getValue(forKey key: Key) -> Value? {
        var ret : Value?
        queue.sync {
            ret = self.dictStorage[key]
            self.accessMapQueue.async {
                self.accessCountMap[key] = (self.accessCountMap[key] ?? 0) + 1
            }
        }
        return ret
    }
    
    private func write(block: @escaping ()->()) {
        queue.async (flags: .barrier){
            block()
        }
    }
}
