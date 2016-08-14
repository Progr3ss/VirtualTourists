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
import CoreLocation

class mapViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	
	@IBOutlet weak var editBarButton: UIBarButtonItem!
	var appDelegate: AppDelegate!
	
	var managedContext: NSManagedObjectContext!
	
	
	var locationManager = CLLocationManager()
	var checkPinDrop: Bool = true
	var checkPinEdit: Bool = false
	

    override func viewDidLoad() {
        super.viewDidLoad()
		coreDataManager()
		detectLongPress()

    }


    


}
extension mapViewController{
	
	func coreDataManager(){
		appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		managedContext = appDelegate.managedObjectContext
		
	}
	
	func detectLongPress() {
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapViewController.dropPins(_:)))
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
			var pin = Pin(pinLatitude: touchMapCoordinate.latitude, pinLongitude: touchMapCoordinate.longitude, context: appDelegate.managedObjectContext)
			print("\(pin.latitude) and \(pin.longitude)")
			//add the pin to the map
			mapView.addAnnotation(pin)
			
			//save our context. We can do this at any point but it seems like a good idea to do it here.
			appDelegate.saveContext()
		}
	}
	
	func retrievePins() -> [Pin] {
		
		let error: NSErrorPointer = nil
		// create fetchRequest
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		// Execute fetchRequest
		let results: [AnyObject]?
		
		do {
			results = try managedContext.executeFetchRequest(fetchRequest)
		} catch let error1 as NSError {
			error.memory = error1
			results = nil
		}
		
		// Check for Errors
		if error != nil {
			print("Error retrieving pins \(error)")
		}
		// Return the results
//		print("Pins \(results)")
		return results as! [Pin]
	}

	
}

extension mapViewController: MKMapViewDelegate {
	
	@IBAction func editButtonPressed(sender: AnyObject) {
		
		if checkPinEdit {
			checkPinEdit = false
			editBarButton.title = "Edit"
			view.frame.origin.y +=  CGFloat(60.0)
			
			

		
		}else {
			checkPinEdit = true
			editBarButton.title = "Done"
			view.frame.origin.y -=  CGFloat(60.0)

		}

	}
	
	

	
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

		performSegueWithIdentifier("PhotoDetail", sender: view)
		
		
		
		//check if Done
		if editBarButton.title == "Done"{
			//create pin
			let pin = view.annotation as! Pin
			//delete from  context
			managedContext.deleteObject(pin)
			//remove the annotation from the map
			mapView.removeAnnotation(pin)
			//save our context
			appDelegate.saveContext()
			
			
		}
		
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "PhotoDetail" {
			
			var pins = retrievePins()
			
			

			for pin in pins {
				print("pin \(pin.latitude! )")
				print("pin \(pin.longitude!)")
				
			}
			
			if let destinationVC = segue.destinationViewController as? PhotosViewController{
				//TO-DO: Need to pass pins to PhotosViewController
//				destinationVC.latitude = 
//				destinationVC.longitude =
			}
			
			
			
			
	
			
		
	}
}
	
}

