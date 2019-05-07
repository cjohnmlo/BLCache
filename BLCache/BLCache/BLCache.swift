//
//  BLCache.swift
//  BLCache
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

public class BLCache<E: KeyInitialisable> {
    
    private var blockCache = Dictionary<String, [cacheGetBlock]>()
    private var cacheStorage : BLCacheStorage<String, E.ObjectType>
    private var serialQueue = DispatchQueue(label: "com.bl.blockqueue", qos: DispatchQoS.userInitiated)
    
    public init(limit inBytes: UInt) {
        self.cacheStorage = BLCacheStorage<String, E.ObjectType>(limit: inBytes)
    }
    
    public func entity(forKey key: String, completion : @escaping cacheGetBlock)  {
        if let res = self.cacheStorage.getValue(forKey: key) {
            DispatchQueue.main.async {
                completion(res)
            }
        }
        else {
            var process = false
            serialQueue.sync {
                if let blocks = self.blockCache[key] {
                    self.blockCache[key] = blocks + [completion]
                }
                else {
                    // first block, assume that no processing is being done yet
                    self.blockCache[key] = [completion]
                    process = true
                }
            }
            if process {
                // get the property using the key
                self.processEntity(usingKey: key)
            }
        }
    }
    
    private func processEntity(usingKey key: String) {
        E.instanceFrom(key: key) { newinstance in
            
            if let ent = newinstance {
                self.cacheStorage.set(value: ent, forKey: key, size: ent.sizeInBytes())
            }
            
            // fire all the completion blocks that requested for this key
            self.serialQueue.sync {
                guard let blocks = self.blockCache[key] else {
                    return
                }
                self.blockCache[key] = nil
                
                for block in blocks {
                    DispatchQueue.main.async {
                        block(newinstance)
                    }
                }
            }
        }
    }
    
    public typealias cacheGetBlock = (E.ObjectType?) -> ()
}


