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
	
	@IBOutlet weak var editBarButton: UIBarButtonItem!
	var appDelegate: AppDelegate!
	var managedContext: NSManagedObjectContext!
	
	
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
		mapView.addGestureRecognizer(longPress)
		mapView.delegate = self
		mapView.addAnnotations(retrievePins())
	
	}
	func dropPins(gestureRecognizer: UIGestureRecognizer){
		let pinPoint: CGPoint = gestureRecognizer.locationInView(mapView)
		let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(pinPoint, toCoordinateFromView: mapView)
		
		if UIGestureRecognizerState.Began == gestureRecognizer.state {
			let pin = Pin(pinLatitude: touchMapCoordinate.latitude, pinLongitude: touchMapCoordinate.longitude, context: appDelegate.managedObjectContext)
            
            pin.flickr.loadNewPhotos(appDelegate.managedObjectContext, handler: { _ in
              performUIUpdatesOnMain({ 
				
				 self.appDelegate.saveContext()
			})
            })
			mapView.addAnnotation(pin)
			appDelegate.saveContext()
		}
	}
	
	func retrievePins() -> [Pin] {
		
		let error: NSErrorPointer = nil
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		let results: [AnyObject]?
		
		do {
			results = try managedContext.executeFetchRequest(fetchRequest)
		} catch let error1 as NSError {
			error.memory = error1
			results = nil
		}
	
		if error != nil {
			print("Error retrieving pins \(error)")
		}
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

		
		let pin = view.annotation as! Pin
        mapView.deselectAnnotation(pin, animated: false)
		if editBarButton.title == "Done"{
  
			managedContext.deleteObject(pin)
			mapView.removeAnnotation(pin)
			appDelegate.saveContext()
			
			
        } else {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoVC") as! PhotosViewController
            
            controller.pin = pin
            navigationController!.pushViewController(controller, animated: true)
        }
		
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "PhotoDetail" {
			
			print("segued")
			
		
	}
}
}