//
//  Pin.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/12/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation{

// Insert code here to add functionality to your managed object subclass
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
	{
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	
	init(pinLatitude: Double, pinLongitude: Double, context: NSManagedObjectContext) {
		
		//create entity for pin
		let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
		
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		//Assign NSNumber to long and lat
		latitude = NSNumber(double: pinLatitude)
		
		longitude = NSNumber(double: pinLongitude)
	}
	
	//confirm to the protocal
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double)
	}

}
