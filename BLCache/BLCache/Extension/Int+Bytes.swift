//
//  Int+Bytes.swift
//  BLCache
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

extension Int {
    var byte : Int {
        return self
    }
    
    var kilobyte : Int {
        return self * 1000
    }
    
    var megabyte : Int {
        return self.kilobyte * 1000
    }
    
    var gigabyte : Int {
        return self.megabyte * 1000
    }
}
