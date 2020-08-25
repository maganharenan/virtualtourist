//
//  PhotoAlbumController+DataSource.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 20/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit
import CoreData

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellView.identifier, for: indexPath) as! PhotoCellView
        cell.imageView.image = UIImage(contentsOfFile: "1024x1024")
        cell.activityIndicatorView.startAnimating()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoCell = cell as! PhotoCellView
        photoCell.imageUrl = photo.imageURL!
        handleCollectionCellImage(cell: photoCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
}
