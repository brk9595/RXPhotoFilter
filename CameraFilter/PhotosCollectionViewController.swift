//
//  PhotosCollectionViewController.swift
//  CameraFilter
//
//  Created by Mohammad Azam on 2/13/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotosCollectionViewController: UIViewController {
    
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }
    
    private var collectionView: UICollectionView!
    private var images = [PHAsset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Photos"
        self.view.backgroundColor = .white
        setupCollectionViewLayout()
        setUpCollectionView()
        populatePhotos()
    }
    
    func setUpCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func populatePhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            if status == .authorized {
                //Access the photos from the library
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                
                assets.enumerateObjects { (object ,count, stop) in
                    self?.images.append(object)
                }
                self?.images.reverse()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func setupCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 70, height: 70)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
    }
    
}

extension PhotosCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        let asset = self.images[indexPath.item]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 70, height: 70), contentMode: .aspectFit, options: nil) {
            image,_ in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = self.images[indexPath.row]
        
        PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) {
            [weak self] image, info in
            guard let info = info else {return}
            if let image = image {
                self?.selectedPhotoSubject.onNext(image)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
}
