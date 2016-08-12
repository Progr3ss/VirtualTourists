//
//  mapViewController.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/12/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class mapViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	
	var appDelegate: AppDelegate!
	var managedContext: NSManagedObjectContext!
	

    override func viewDidLoad() {
        super.viewDidLoad()
		coreDataManager()
		detectLongPress()
		
	
		

        // Do any additional setup after loading the view.
    }


    


}
extension mapViewController{
	
	func coreDataManager(){
		appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		managedContext = appDelegate.managedObjectContext
		
	}
	
	func detectLongPress() {
		let longPress = UILongPressGestureRecognizer(target: self, action: "dropPins:")
		longPress.minimumPressDuration = 0.5
		
		//add to map
		mapView.addGestureRecognizer(longPress)
		mapView.delegate = self
		//add pins 
		mapView.addAnnotations(retrievePins())
	
	}
	func dropPins(gestureRecognizer: UIGestureRecognizer){
		let pinPoint: CGPoint = gestureRecognizer.locationInView(mapView)
		let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(pinPoint, toCoordinateFromView: mapView)
		
		if UIGestureRecognizerState.Began == gestureRecognizer.state {
			//initialize our Pin with our coordinates and the context from AppDelegate
			let pin = Pin(pinLatitude: touchMapCoordinate.latitude, pinLongitude: touchMapCoordinate.longitude, context: appDelegate.managedObjectContext)
			//add the pin to the map
			mapView.addAnnotation(pin)
			//save our context. We can do this at any point but it seems like a good idea to do it here.
			appDelegate.saveContext()
		}
	}
	
	func retrievePins() -> [Pin] {
		
		let error: NSErrorPointer = nil
		// Create the Fetch Request
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		// Execute the Fetch Request
		let results: [AnyObject]?
		do {
			results = try managedContext.executeFetchRequest(fetchRequest)
		} catch let error1 as NSError {
			error.memory = error1
			results = nil
		}
		// Check for Errors
		if error != nil {
			print("Error in fectchAllActors(): \(error)")
		}
		// Return the results, cast to an array of Pin objects
		return results as! [Pin]
	}
	

	
	
	
}

extension mapViewController: MKMapViewDelegate {
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		//cast pin
		let pin = view.annotation as! Pin
		//delete from our context
		managedContext.deleteObject(pin)
		//remove the annotation from the map
		mapView.removeAnnotation(pin)
		//save our context
		appDelegate.saveContext()
	}
	
}