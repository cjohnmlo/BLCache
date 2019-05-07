//
//  KeyInitialisable.swift
//  BLCache
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

public protocol KeyInitialisable {
    associatedtype ObjectType: KeyInitialisable = Self
    static func instanceFrom(key keyString: String, completion: @escaping (ObjectType?) -> Void)
    func sizeInBytes() -> UInt
}
