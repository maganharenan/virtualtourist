//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 05/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    //MARK: - Methods
    
    ///Fetch the results of pin entity
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.viewContext, sectionNameKeyPath: nil, cacheName: "pins")

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        showAllLoadedPins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

    @IBAction func dropAPinWhenLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        ///Converts a point in the specified view’s coordinate system to a map coordinate.
        let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
        ///When the gesture starts, add the pin to the map
        if sender.state == .began {
            createPin(from: locationCoordinate)
        ///When the gesture ends, stores the pin to the data source
        } else if sender.state == .ended {
            savePinToDataBase(from: locationCoordinate)
        }
    }
    
    func createPin(from coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    func savePinToDataBase(from coordinate: CLLocationCoordinate2D) {
        let newPin = Pin(context: appDelegate.viewContext)
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        newPin.creationDate = Date()
        appDelegate.saveContext()
    }
    
    ///After fetch the results of the pin entity from data source, show this results into the map view
    func showAllLoadedPins() {
        for pin in fetchedResultsController.fetchedObjects ?? [] {
            let annotation = MKPointAnnotation()
            let lat = pin.latitude
            let lon = pin.longitude
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
    }
    
    ///Try to fetch the results of a specific pin and returns it
    func fetchSpecificPin(_ predicate: NSPredicate, entityName: String, sortDescriptor: NSSortDescriptor? = nil) throws -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        guard let pin = (try appDelegate.viewContext.fetch(fetchRequest) as! [Pin]).first else {
            return nil
        }
        return pin
    }
    
    ///Sends the coordinates to the fetch request of a specific pin
    func loadFetchedPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = fetchSpecificPin(predicate, entityName: "Pin")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return pin
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController {
            guard let pin = sender as? Pin else {
                return
            }
            vc.pin = pin
        }
    }
}



