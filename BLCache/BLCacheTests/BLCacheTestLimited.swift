//
//  BLCacheTestLimited.swift
//  BLCacheTestLimited
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

import XCTest
import Foundation
@testable import BLCache

class BLCacheTestLimited: XCTestCase {
    
    var cache : BLCache<MockBigClass>?
    var resultSet : Set<MockBigClass>?
    let resultSetQueue = DispatchQueue(label: "com.bl.test.queue", qos: .default)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache = BLCache<MockBigClass>(limit: UInt(7.megabyte))
        resultSet = Set<MockBigClass>()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resultSet?.removeAll()
        cache = nil
    }
    
    func testKeyAisRemovedOnce() {
        let exp = expectation(description: "A is recreated")
        DispatchQueue.main.async {
            self.cache?.entity(forKey: "A", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.async {
            self.cache?.entity(forKey: "B", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
            
            self.cache?.entity(forKey: "B", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            self.cache?.entity(forKey: "C", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.cache?.entity(forKey: "A", completion: { (result) in
                if let res = result {
                    assert(!((self.resultSet?.contains(res))!))
                    assert(self.resultSet?.count == 3)
                    exp.fulfill()
                }
                else {
                    assertionFailure("A not created")
                }
            })
        }
        
        wait(for: [exp], timeout: 10.0)
        
    }
    
    func testKeyAandBisRemoved() {
        let exp = expectation(description: "A is recreated")
        let exp2 = expectation(description: "B is recreated")
        DispatchQueue.main.async {
            self.cache?.entity(forKey: "A", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.async {
            self.cache?.entity(forKey: "B", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            self.cache?.entity(forKey: "D", completion: { (result) in
                if let res = result {
                    self.writeToResult(e: res)
                }
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.cache?.entity(forKey: "A", completion: { (result) in
                if let res = result {
                    assert(!((self.resultSet?.contains(res))!))
                    assert(self.resultSet?.count == 3)
                    exp.fulfill()
                }
                else {
                    assertionFailure("A not created")
                }
            })
            
            self.cache?.entity(forKey: "B", completion: { (result) in
                if let res = result {
                    assert(!((self.resultSet?.contains(res))!))
                    assert(self.resultSet?.count == 3)
                    exp2.fulfill()
                }
                else {
                    assertionFailure("B not created")
                }
            })
        }
        
        wait(for: [exp, exp2], timeout: 10.0)
    }
    
    
    class MockBigClass : NSObject, KeyInitialisable {
        var size : UInt = 0
        static func instanceFrom(key keyString: String, completion: @escaping (BLCacheTestLimited.MockBigClass?) -> Void) {
            let rand = Double.random(in: 0 ..< 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + rand) {
                let instance = MockBigClass()
                if keyString == "A" {
                    instance.size = UInt(1.megabyte)
                }
                else if keyString == "B" {
                    instance.size = UInt(3.megabyte)
                }
                else if keyString == "C" {
                    instance.size = UInt(4.megabyte)
                }
                else if keyString == "D" {
                    instance.size = UInt(7.megabyte)
                }
                completion(instance)
            }
        }
        
        func sizeInBytes() -> UInt {
            return self.size
        }
    }
    
    func writeToResult(e: MockBigClass) {
        resultSetQueue.async {
            self.resultSet?.insert(e)
        }
    }
    
    
}
