//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/18/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//


import Foundation
import CoreData
import MapKit

extension Photo{
    @NSManaged var id: String
    @NSManaged var path: String
    @NSManaged var pin: Pin
	@NSManaged var flickrImage: NSData?
        
}