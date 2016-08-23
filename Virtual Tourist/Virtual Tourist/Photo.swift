//
//  Photo.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/14/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {

	/* Cache method was inspired by https://github.com/egorio/udacity-virtual-tourist */
    private let nsCache: NSCache = {
        let cache = NSCache()
        cache.name = "cache"
        cache.countLimit = 200
        cache.totalCostLimit = (cache.countLimit / 2) * 1024 * 1024
        return cache
    }()
    
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
        self.path = url
        self.pin = pin
    }

    init(flickrDictionary: [String: AnyObject], pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.id = flickrDictionary["id"] as! String
        self.path = flickrDictionary[Constants.FlickrResponseKeys.MediumURL] as! String
        self.pin = pin
    }

    func get(forKey: String) -> UIImage? {
        return nsCache.objectForKey(forKey) as? UIImage
    }
    
    func getFile(forPath: String) -> UIImage? {
        return UIImage(contentsOfFile: forPath)
    }
    
    
    func setFile(data: UIImage, forPath: String) {
        UIImagePNGRepresentation(data)!.writeToFile(forPath, atomically: true)
        
    }
    
    
    func removeFile(forPath: String) {
        if NSFileManager.defaultManager().fileExistsAtPath(forPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(forPath)
                
            } catch { }
        }
    }
	
    func startLoadingImage(handler: (image : UIImage?, error: String?) -> Void) {

        if let image = get(filePath) {
			
			
		
			
            return handler(image: image, error: nil)
        }


        if let image = self.getFile(filePath) {
			
            return handler(image: image, error: nil)
        }


        cancelLoadingImage()

        task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: path)!)) { data, response, downloadError in
			
			performUIUpdatesOnMain({ 
				
				guard downloadError == nil else {
					
					return handler(image: nil, error: "Photo loadnig canceled")
				}
				
				guard let data = data, let image = UIImage(data: data) else {
					
					return handler(image: nil, error: "Photo not loaded")
				}
				
				
			
				let imgData = UIImageJPEGRepresentation(image, 1)
				self.flickrImage = imgData
				self.set(self.flickrImage!, forKey: self.filePath)
				self.setFile(image, forPath: self.filePath)
				
				
				return handler(image: image, error: nil)
			})
        }
        task!.resume()
    }

    func cancelLoadingImage() {
        task?.cancel()
    }
	

    func set(data: NSData, forKey: String) {

        nsCache.setObject(data, forKey: forKey)

    }
    
    func remove(forKey: String) {
        nsCache.removeObjectForKey(forKey)
    }
   
    override func prepareForDeletion() {
        super.prepareForDeletion()

        self.remove(self.filePath)
        self.removeFile(self.filePath)
    }
}