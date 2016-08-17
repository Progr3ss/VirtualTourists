//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import UIKit

class MemoryCache {

    static private let shared: NSCache = {
        let cache = NSCache()
        cache.name = "cache"
        cache.countLimit = 200
        cache.totalCostLimit = (cache.countLimit / 2) * 1024 * 1024 
        return cache
    }()


    static func get(forKey: String) -> UIImage? {
        return shared.objectForKey(forKey) as? UIImage
    }


    static func set(data: UIImage, forKey: String) {
        shared.setObject(data, forKey: forKey, cost: (UIImageJPEGRepresentation(data, 0)?.length) ?? 0)
    }


    static func remove(forKey: String) {
        shared.removeObjectForKey(forKey)
    }
}