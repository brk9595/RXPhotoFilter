//
//  FilterService.swift
//  CameraFilter
//
//  Created by Bharath Raj Kumar B on 19/10/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import RxSwift
class FilterService {
    private var context: CIContext
    
    init() {
        self.context = CIContext()
    }
    
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        return Observable<UIImage>.create { observer in
            self.applyFilter(to: inputImage) {
                filteredImage in
                observer.onNext(filteredImage)
            }
            return Disposables.create()
        }
    }
    
    private func applyFilter(to inputImage: UIImage, completion: @escaping ((UIImage) -> ())) {
        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(3.0, forKey: kCIInputWidthKey)
        guard let sourceImage = CIImage(image: inputImage) else {return}
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        if let cgImg = self.context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
            let processedImg = UIImage(cgImage: cgImg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
            completion(processedImg)
        }
    }
}
