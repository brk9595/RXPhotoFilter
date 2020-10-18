//
//  ViewController.swift
//  CameraFilter
//
//  Created by Mohammad Azam on 2/13/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let filterChangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filter", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 7
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apply Filters"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .white
        setRightBarButton()
        setupImageView()
        setupFilterButton()
    }
    
    func setRightBarButton() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addPhotosnavigation))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func addPhotosnavigation() {
        let navController = UINavigationController(rootViewController: PhotosCollectionViewController())
        self.present(navController, animated: true, completion: nil)
        let photoVC = navController.viewControllers.first as! PhotosCollectionViewController
        
        photoVC.selectedPhoto.subscribe(onNext: {
            [weak self] photo in
            DispatchQueue.main.async {
                self?.updateUI(with: photo)
            }
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(with image: UIImage) {
        self.imageView.image = image
        filterChangeButton.isHidden = false
    }
    
    func setupImageView() {
        view.addSubview(imageView)
        imageView.backgroundColor = .systemGreen
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
        ])
    }
    
    func setupFilterButton() {
        view.addSubview(filterChangeButton)
        
        NSLayoutConstraint.activate([
            filterChangeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            filterChangeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            filterChangeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterChangeButton.heightAnchor.constraint(equalToConstant: 46),
            imageView.bottomAnchor.constraint(equalTo: filterChangeButton.topAnchor, constant: -30)
        ])
        filterChangeButton.addTarget(self, action: #selector(filterButtonAction), for: .touchUpInside)
        filterChangeButton.isHidden = true
    }
    
    @objc func filterButtonAction() {
        guard let sourceImg = self.imageView.image else { return }
        
        FilterService().applyFilter(to: sourceImg)
            .subscribe(onNext: { filteredImage in
                
                DispatchQueue.main.async {
                    self.imageView.image = filteredImage
                }
                
            }).disposed(by: disposeBag)
    }
    
    
}

