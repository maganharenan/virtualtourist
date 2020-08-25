//
//  APIClient.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 18/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import Foundation

class APIClient {
    
    static let apiKey = "0a7e1179f73468f0ba09d3e87c1241f7"
    
    func getTotalOfPages(latitude: String, longitude: String, completion: @escaping (Int?, Error?) -> Void ) {
        let lat = Double(latitude)!
        let lon = Double(longitude)!
        let urlString = Endpoints.getTotalPages(APIClient.apiKey, lat, lon).stringValue
        let url = URL(string: urlString)
        let _ = taskForGetRequest(url: url!, responseType: PhotoResponse.self) { (response, error) in
            if let response = response?.photos.pages {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func searchPhotosByCoordinates(latitude: String, longitude: String, page: String, completion: @escaping (PhotoResponse?, Error?) -> Void ) {
        let lat = Double(latitude)!
        let lon = Double(longitude)!
        let urlString = Endpoints.searchPhotos(APIClient.apiKey, lat, lon, page).stringValue
        let url = URL(string: urlString)
        let _ = taskForGetRequest(url: url!, responseType: PhotoResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func downloadImageTask(imageURL: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: imageURL)
        
        guard let urlToDownload = url else {
            completion(nil, nil)
            return
        }
        
        let request = URLRequest(url: urlToDownload)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completion(data, nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
