//
//  BLCacheTests.swift
//  BLCacheTests
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

import XCTest
import Foundation
@testable import BLCache

class BLCacheTests: XCTestCase {
    
    var cache : BLCache<MockBigClassNoMem>?
    var resultSet : Set<MockBigClassNoMem>?
    let resultSetQueue = DispatchQueue(label: "com.bl.test.queue", qos: .default)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache = BLCache<MockBigClassNoMem>(limit: UInt(5.megabyte))
        resultSet = Set<MockBigClassNoMem>()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resultSet?.removeAll()
        cache = nil
    }

    func testNoMemoryLimit() {
        let exp = expectation(description: "Set only has 3 instances")
        
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "A", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "B", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "C", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            for _ in 1...5 {
                self.cache?.entity(forKey: "A", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                
                self.cache?.entity(forKey: "B", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                
                self.cache?.entity(forKey: "C", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            assert(self.resultSet?.count == 3)
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 10.0)
    }
    
    func testNoMemoryLimitMoreBlocks() {
        let exp = expectation(description: "Set only has 3 instances")
        
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "A", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                self.cache?.entity(forKey: "C", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "B", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                self.cache?.entity(forKey: "A", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            for _ in 1...50 {
                self.cache?.entity(forKey: "B", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                self.cache?.entity(forKey: "C", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            for _ in 1...5 {
                self.cache?.entity(forKey: "A", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                
                self.cache?.entity(forKey: "B", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
                
                self.cache?.entity(forKey: "C", completion: { (result) in
                    if let res = result {
                        self.writeToResult(e: res)
                    }
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            assert(self.resultSet?.count == 3)
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 10.0)
    }

    class MockBigClassNoMem : NSObject, KeyInitialisable {
        static func instanceFrom(key keyString: String, completion: @escaping (BLCacheTests.MockBigClassNoMem?) -> Void) {
            let rand = Double.random(in: 0 ..< 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + rand) {
                completion(MockBigClassNoMem())
            }
        }
        
        func sizeInBytes() -> UInt {
            return 0
        }
    }
    
    func writeToResult(e: MockBigClassNoMem) {
        resultSetQueue.async {
            self.resultSet?.insert(e)
        }
    }
    

}
