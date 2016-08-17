//
//  PinFlickr.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 7/21/16.
//  Copyright © 2016 martin chibwe. All rights reserved.

import Foundation
import CoreData
import UIKit
class PinFlickr: NSManagedObject {
    var session: NSURLSession { return NSURLSession.sharedSession() }
    
    
    var headers: [String: String] = [String: String]()
    
    let urlofAPI = "https://api.flickr.com/services/rest/"
    

    @NSManaged var nextPage: Int32
    @NSManaged var totalPages: Int32
    @NSManaged var pin: Pin


    var loading = false

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(nextPage: Int32 = 1, totalPages: Int32 = 1, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("PinFlickr", inManagedObjectContext: context)

        super.init(entity: entity!, insertIntoManagedObjectContext: context)

        self.nextPage = nextPage
        self.totalPages = totalPages
    }


    func loadNewPhotos(context: NSManagedObjectContext, handler: (error: String?) -> Void) {
        if loading {
            return handler(error: "Loading in progress")
        }

        loading = true
        searchPhotosByCoordinate(pin.latitude as! Double, longitude: pin.longitude as! Double, page: Int(nextPage)) { (photos, pages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                guard error == nil else {
                    return handler(error: error)
                }

                for photo in photos! where photo["url_m"] != nil {
                    _ = Photo(flickrDictionary: photo, pin: self.pin, context: context)
                    
                }

                self.loading = false

				
                self.totalPages = Int32(min(10, pages))
                self.nextPage = Int32(self.totalPages >= (self.nextPage + 1) ? self.nextPage + 1 : 1)
          

                return handler(error: nil)
            })
        }
    }
    
    func searchPhotosByCoordinate(latitude: Double, longitude: Double, page: Int = 1, handler: (photos: [[String : AnyObject]]?, pages: Int, error: String?) -> Void) {
        
        let minmumLon = max(longitude-(Constants.Flickr.SearchBBoxHalfWidth), Constants.Flickr.SearchLonRange.0)
        
        let minimuLat = max(latitude - (Constants.Flickr.SearchBBoxHalfHeight), Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximuLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
               
        let params = [
            "method": "flickr.photos.search",
            "api_key": Constants.FlickrParameterValues.APIKey,
            "bbox": "\(minmumLon),\(minimuLat),\(maximumLon),\(maximuLat)",
            "safe_search": "1",
            "extras": "url_m",
            "format": "json",
            "nojsoncallback": "1",
            "per_page": "30",
            "page": String(page),
            ]
        
        let url = "\(urlofAPI)" + "?" + encodeParameters(params)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard error == nil else {
                print("Error in response")
                handler(photos: nil, pages: 0, error: "Connection error")
                return
            }
            
            // Did we get a successful 2XX response?
            guard let status = (response as? NSHTTPURLResponse)?.statusCode where status != 403 else {
                handler(photos: nil, pages: 0, error: "Username or password is incorrect")
                return
            }
            
            
            guard let data = data else {
                handler(photos: nil, pages: 0, error: "Connection error")
                return
            }
            
            let json: AnyObject!
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                handler(photos: nil, pages: 0, error: "Connection error")
                return
            }
            
            guard let photoData = json!["photos"] as? [String : AnyObject] else {
                
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }
            print(json)
            
            guard let pages = photoData["pages"] as? Int else {
                
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }
            
            guard let results = photoData["photo"] as? [[String : AnyObject]] else {
                
                handler(photos: nil, pages: 0, error: "Wrong response")
                return
            }
            
            handler(photos: results, pages: pages, error: nil)
        }
        
        task.resume()
    }
    
    func encodeParameters(params: [String: AnyObject]) -> String {
        let components = NSURLComponents()
        components.queryItems = params.map { NSURLQueryItem(name: $0, value: String($1)) }
        
        return components.percentEncodedQuery ?? ""
    }
}
