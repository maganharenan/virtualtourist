//
//  PhotoCellView.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 18/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit

class PhotoCellView: UICollectionViewCell {
    static let identifier = "PhotoCellView"
    
    var imageUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
}
