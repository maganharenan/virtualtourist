//
//  PhotoAlbumController+Delegate.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 16/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import UIKit
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        appDelegate.viewContext.delete(photoToDelete)
        appDelegate.saveContext()
    }
}
