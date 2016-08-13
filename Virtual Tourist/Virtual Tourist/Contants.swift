//
//  Contants.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/12/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import Foundation
// MARK: - Constants
struct Constants {
	
	// MARK: Flickr
	struct Flickr {

		
		static let APIScheme = "https"
		static let APIHost = "api.flickr.com"
		static let APIPath = "/services/rest"
		
		static let SearchBBoxHalfWidth = 1.0
		static let SearchBBoxHalfHeight = 1.0
		static let SearchLatRange = (-90.0, 90.0)
		static let SearchLonRange = (-180.0, 180.0)
	}
	
	// MARK: Flickr Parameter Keys
	struct FlickrParameterKeys {
		static let Method = "method"
		static let APIKey = "api_key"
		static let GalleryID = "gallery_id"
		static let Extras = "extras"
		static let Format = "format"
		static let NoJSONCallback = "nojsoncallback"
	}
	
	// MARK: Flickr Parameter Values
	struct FlickrParameterValues {
		static let APIKey = "992be9fde0cec02a3402cb050516f4a8"
		static let ResponseFormat = "json"
		static let DisableJSONCallback = "1" /* 1 means "yes" */
		static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
		static let GalleryID = "5704-72157622566655097"
		static let MediumURL = "url_m"
	}
	
	// MARK: Flickr Response Keys
	struct FlickrResponseKeys {
		static let Status = "stat"
		static let Photos = "photos"
		static let Photo = "photo"
		static let Title = "title"
		static let MediumURL = "url_m"
	}
	
	// MARK: Flickr Response Values
	struct FlickrResponseValues {
		static let OKStatus = "ok"
	}
}