//
//  Photo.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/23/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var url: String
    @NSManaged var pin: Pin


    var task: NSURLSessionTask? = nil

	
    lazy var filePath: String = {
        return NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            .URLByAppendingPathComponent("image-\(self.id).jpg").path!
    }()

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(id: String, url: String, pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.id = id
        self.url = url
        self.pin = pin
    }


    init(flickrDictionary: [String: AnyObject], pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.id = flickrDictionary["id"] as! String
        self.url = flickrDictionary["url_m"] as! String
        self.pin = pin
    }

	
    func startLoadingImage(handler: (image : UIImage?, error: String?) -> Void) {

        if let image = MemoryCache.get(filePath) {
			
            return handler(image: image, error: nil)
        }


        if let image = FileCache.get(filePath) {
			
            return handler(image: image, error: nil)
        }


        cancelLoadingImage()

        task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!)) { data, response, downloadError in
            dispatch_async(dispatch_get_main_queue(), {
                guard downloadError == nil else {
					
                    return handler(image: nil, error: "Photo loadnig canceled")
                }

                guard let data = data, let image = UIImage(data: data) else {

                    return handler(image: nil, error: "Photo not loaded")
                }

                MemoryCache.set(image, forKey: self.filePath)
                FileCache.set(image, forPath: self.filePath)

				
                return handler(image: image, error: nil)
            })
        }
        task!.resume()
    }

    func cancelLoadingImage() {
        task?.cancel()
    }

   
    override func prepareForDeletion() {
        super.prepareForDeletion()

        MemoryCache.remove(self.filePath)
        FileCache.remove(self.filePath)
    }
}