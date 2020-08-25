//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 16/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newAlbumButton: UIBarButtonItem!
    var totalOfPages: Int?
    
    //MARK: - Methods
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin!)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFlowLayout()
        createPinAnnotation()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        labelView.isHidden = true
        fetchPhotos()
        setupFetchedResultsController()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureFlowLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    //MARK: - Search and Store Photos
    
    ///Verifies if there are photos stored in the database
    func fetchPhotos() {
        if let photos = pin.photos {
            if photos.count == 0 {
                getTotalPagesNumber()
                //if the are no photos stored in the database then
                getPinImagesFromAPI(latitude: String(pin.latitude), longitude: String(pin.longitude))
            }
        }
    }
    
    ///Call the API method that searches for the images and their respective handler
    func getPinImagesFromAPI(latitude: String, longitude: String) {
        APIClient().searchPhotosByCoordinates(latitude: latitude, longitude: longitude, page: getRandomPageNumber(), completion: handleSearchPhotosResponse(response:error:))
    }
    
    ///Generates a random number between 0 and the number of pages  of the search result
    func getRandomPageNumber() -> String {
        var randomPage: String = ""
        if let totalOfPages = totalOfPages {
            randomPage = "\(Int.random(in: 0...totalOfPages))"
        }
        return randomPage
    }
    
    ///Handles the search photos result
    ///If the search does not return any results, then shows a message
    ///If the search  return any results, then call the method to save the results into the datastore
    func handleSearchPhotosResponse(response: PhotoResponse?, error: Error?) {
        if let response = response {
            if response.photos.pages == 0 {
                DispatchQueue.main.async {
                    self.labelView.text = "There is no photos for this location"
                    self.labelView.isHidden = false
                }
            } else {
                storeSearchResults(response: response)
            }
        } else {
            print("Error: \(error?.localizedDescription ?? "some error")")
        }
    }
    
    ///Fetches the photos for the coordinates to get the total of pages from that search
    func getTotalPagesNumber() {
        APIClient().getTotalOfPages(latitude: String(pin.latitude), longitude: String(pin.longitude)) { (response, error) in
            if let response = response {
                self.totalOfPages = response
            } else {
                self.totalOfPages = 0
            }
        }
    }
    
    ///Store each result that contains the https protocol
    private func storeSearchResults(response: PhotoResponse) {
        
        for photo in response.photos.photo {
            
            if photo.url_m.contains("https://") || photo.url_m.contains("http://") {
                let newPhotoForStore = Photo(context: appDelegate.viewContext)
                newPhotoForStore.imageURL = photo.url_m
                newPhotoForStore.image = nil
                newPhotoForStore.creationDate = Date()
                newPhotoForStore.pin = self.pin!
                appDelegate.saveContext()
            }
        }
    }
    
    //MARK: - Map Properties and Methods
    
    func createPinAnnotation() {
        let annotation = MKPointAnnotation()
        let lat = pin.latitude
        let lon = pin.longitude
        annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    //MARK: - PhotoCell Image configuration and datastore saving flow
    
    func handleCollectionCellImage(cell: PhotoCellView, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicatorView.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: imageData as NSData))
        } else {
            cell.activityIndicatorView.startAnimating()
            if let imageUrl = photo.imageURL {
                startDownloadImageData(index: index, imageUrl: imageUrl, photo: photo, cell: cell)
            }
        }
    }
    
    func startDownloadImageData(index: IndexPath, imageUrl: String, photo: Photo, cell: PhotoCellView) {
        APIClient().downloadImageTask(imageURL: imageUrl) { (response, error) in
            if let response = response {
                self.handleDownloadImageTask(response: response, index: index, imageUrl: imageUrl, photo: photo, cell: cell)
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func handleDownloadImageTask(response: Data, index: IndexPath, imageUrl: String, photo: Photo, cell: PhotoCellView) {
        setImageToCollectionCellItem(index: index, image: response, imageUrl: imageUrl, cell: cell)
            saveDownloadedImageToDataSource(photo: photo, image: response)
    }
    
    func setImageToCollectionCellItem(index: IndexPath, image: Data, imageUrl: String, cell: PhotoCellView) {
        DispatchQueue.main.async {
            if let currentCell = self.collectionView.cellForItem(at: index) as? PhotoCellView {
                if currentCell.imageUrl == imageUrl {
                    currentCell.imageView.image = UIImage(data: image)
                    cell.activityIndicatorView.stopAnimating()
                    cell.activityIndicatorView.isHidden = true
                }
            }
        }
    }
    
    func saveDownloadedImageToDataSource(photo: Photo, image: Data) {
        photo.image = NSData(data: image) as Data
        appDelegate.saveContext()
    }
    
    //MARK: - User action methods
    
    @IBAction func downloadNewAlbum(_ sender: Any) {

        guard let imageObject = fetchedResultsController.fetchedObjects else { return }
        
        for photo in imageObject {
            ///Delete the photo
            appDelegate.viewContext.delete(photo)
            
            ///Tries to save the changes
            appDelegate.saveContext()
        }
        ///Executes the routine to get new photos
        fetchPhotos()
        
    }
    
    func configureFlowLayout() {
        ///Get the size of the view
        let viewSize = view.frame.size
        
        enum DeviceOrientation {
            case portrait
            case landscape
        }
        
        ///Verifies if the device is on the portrait or landscape position
        var deviceOrientation: DeviceOrientation {
            if viewSize.width > viewSize.height {
                return .landscape
            } else {
                return .portrait
            }
        }
        
        ///Set the collection view aspects
        let space: CGFloat = deviceOrientation == .portrait ? 3 : 3
        let numberOfItens: CGFloat = deviceOrientation == .portrait ? 3 : 5
        let dimension = (viewSize.width - (numberOfItens * space)) / numberOfItens
        
        ///Creates and cofigures the flow  layout of the collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView!.collectionViewLayout = layout
    }
}
