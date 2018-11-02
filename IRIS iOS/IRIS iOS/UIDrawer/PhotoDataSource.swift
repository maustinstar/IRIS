//
//  PhotoDataSource.swift
//  IRIS
//
//  Created by Michael Verges on 10/26/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import Photos

protocol PhotoDataSourceDelegate {
    func didSelect(image: UIImage)
}

class PhotoDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView
    lazy var photos: PHFetchResult<PHAsset>! = {
        return PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
    }()
    
    var delegate: PhotoDataSourceDelegate?
    
    var options: PHFetchOptions
    var reuseIdentifier: String = "image"
    
    init(collectionView: UICollectionView, withOptions options: PHFetchOptions) {
        self.options = options
        self.collectionView = collectionView
        super.init()
        collectionView.register(
            UINib(nibName: "ImageCell", bundle: Bundle.main),
            forCellWithReuseIdentifier: "reuseIdentifier")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        // Configure the cell
        if let imageCell = cell as? ImageCell {
            
            let asset = photos!.object(at: indexPath.row)
            
            
            PHImageManager.default().requestImageData(for: asset, options: nil) { (data, string, orientation, _) in
                imageCell.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
}
