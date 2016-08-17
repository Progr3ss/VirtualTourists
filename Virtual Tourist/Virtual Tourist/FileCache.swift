//
//  FileImageCache.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit

class FileCache {

    static private let shared = FileCache()


    static func get(forPath: String) -> UIImage? {
        return UIImage(contentsOfFile: forPath)
    }


    static func set(data: UIImage, forPath: String) {
        UIImagePNGRepresentation(data)!.writeToFile(forPath, atomically: true)
		
    }


    static func remove(forPath: String) {
        if NSFileManager.defaultManager().fileExistsAtPath(forPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(forPath)
              
            } catch { }
        }
    }
}
