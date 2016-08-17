//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/12/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    var appDelegate: AppDelegate!
    var managedContext: NSManagedObjectContext!
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var editBtnFlag: Bool = false
    var pin: Pin? = nil
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var edit_ButtonView: UIBarButtonItem!
    
    @IBAction func okButton(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func editButton(sender: UIBarButtonItem) {
        if editBtnFlag {
            editBtnFlag = false
            edit_ButtonView.title = "Edit"
            view.frame.origin.y +=  CGFloat(60.0)
            newCollectionButtonView.enabled = true
        }else {
            editBtnFlag = true
            edit_ButtonView.title = "Done"
            view.frame.origin.y -=  CGFloat(60.0)
            newCollectionButtonView.enabled = false
        }
        self.view.layoutIfNeeded()
    }
    @IBAction func newCollection(sender: UIBarButtonItem) {
        loadNewPhotos()
    }
    
    @IBOutlet weak var newCollectionButtonView: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataManager()
        mapView.addAnnotation(pin!)
        mapView.setRegion(MKCoordinateRegion(center: pin!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        mapView.userInteractionEnabled = false
        fetchedResultsController.delegate = self
        setupCollectionFlowLayout()
        // Do any additional setup after loading the view.
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    let fetchRequest = NSFetchRequest(entityName: "Pin")
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch { }
        
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadNewPhotos()
        }
    }
    
    func setupCollectionFlowLayout() {
        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((items + 1) * space)) / items
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0 - items
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSizeMake(dimension, dimension)
        
        collectionView.collectionViewLayout = layout
    }
}
extension PhotosViewController
{
    func coreDataManager(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
    }

    func loadNewPhotos() {
        self.newCollectionButtonView.enabled = false
        self.pin!.deletePhotos(appDelegate.managedObjectContext) { _ in }
        self.pin!.flickr.loadNewPhotos(appDelegate.managedObjectContext, handler: { _ in
           self.appDelegate.saveContext()
            self.newCollectionButtonView.enabled = true
        } )
    }
    
}

extension PhotosViewController:UICollectionViewDelegate, UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        cell.photo = photo
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if editBtnFlag {
            appDelegate.managedObjectContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
            appDelegate.saveContext()
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setupCollectionFlowLayout()
    }

}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = []
        deletedIndexPaths = []
    }
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
        case .Delete:
            deletedIndexPaths.append(indexPath!)
        default: ()
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
}
