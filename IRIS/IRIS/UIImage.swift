//
//  UIImage.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

public extension UIImage {
    
    /// - returns: `UIImage` with dimenstions scaled @2x
    public func enhance() -> [Any]? {
        
        do {
            let model = try VNCoreMLModel(for: MobileNet().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
//                self?.processClassifications(for: request, error: error)
            })
            return request.results
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
}
