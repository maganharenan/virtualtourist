//
//  MapViewController+Delegate.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 20/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation else {
            return
        }

        mapView.deselectAnnotation(annotation, animated: true)
        let latitude = String(annotation.coordinate.latitude)
        let longitude = String(annotation.coordinate.longitude)
        if let pin = self.loadFetchedPin(latitude: latitude, longitude: longitude) {
            performSegue(withIdentifier: "showLoadedPinAlbum", sender: pin)
        }
    }
}
