//
//  Endpoints.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 20/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import Foundation

enum Endpoints {
    static let baseURL = "https://api.flickr.com"
    
    case path
    case getTotalPages(String, Double, Double)
    case searchPhotos(String, Double, Double, String)
    
    var stringValue: String {
        switch self {
        case .path: return Endpoints.baseURL + "/services/rest"
        case .getTotalPages(let apiKey, let lat, let lon):
            return Endpoints.path.stringValue +
                "?method=flickr.photos.search" +
                "&api_key=\(apiKey)" +
                "&lat=\(lat)" +
                "&lon=\(lon)" +
                "&per_page=15" +
                "&format=json&nojsoncallback=1&extras=url_m"
        case .searchPhotos(let apiKey, let lat, let lon, let page):
            return Endpoints.path.stringValue +
                "?method=flickr.photos.search" +
                "&api_key=\(apiKey)" +
                "&lat=\(lat)" +
                "&lon=\(lon)" +
                "&per_page=15" +
                "&page=\(page)" +
                "&format=json&nojsoncallback=1&extras=url_m"
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}
