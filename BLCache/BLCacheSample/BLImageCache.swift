//
//  BLImageCache.swift
//  BLCacheSample
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

import Foundation
import BLCache
import UIKit

class BLImageCache {
    static let shared = BLImageCache()
    let cache : BLCache<UIImage>!
    
    private init() {
        cache = BLCache<UIImage>(limit: UInt(100.megabyte))
    }
    
    func getImage(from: String, completion:@escaping (UIImage?) -> ()) {
        self.cache.entity(forKey: from, completion: completion)
    }
}

extension UIImage: KeyInitialisable {
    public static func instanceFrom(key keyString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: keyString) {
            print("calling")
            let _ = URLSession.shared.dataTask(with: url) { (data, respnse, error) in
                if error == nil {
                    if let data = data, let image = UIImage(data: data) {
                        completion(image)
                    }
                    else {
                        completion(nil)
                    }
                }
                else {
                    completion(nil)
                }
            }.resume()
        }
        else {
            completion(nil)
        }
    }
    
    public func sizeInBytes() -> UInt {
        if let data = self.cgImage?.dataProvider?.data as Data? {
            return UInt(MemoryLayout<UIImage>.size + data.count)
        }
        else {
            return UInt(MemoryLayout<UIImage>.size)
        }
    }
    
    
}

