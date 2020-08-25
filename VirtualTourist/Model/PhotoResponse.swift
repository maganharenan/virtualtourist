//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 18/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var photo: [Photo]
    
    struct Photo: Codable {
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        let ispublic: Int
        let isfriend: Int
        let isfamily: Int
        let url_m: String
    }
}
