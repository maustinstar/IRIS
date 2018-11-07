//
//  CGImage.swift
//  IRIS
//
//  Created by Michael Verges on 10/23/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

public extension CGImage {
    public func patch(at position: (Int, Int), size: (Int, Int)) -> Patch? {
        let rect = CGRect(
            origin: CGPoint(x: position.0, y: position.1),
            size: CGSize(width: size.0, height: size.1))
        
        return self.patch(in: rect)
    }
    
    public func patch(in rect: CGRect) -> Patch? {
        guard let cropped = self.cropping(to: rect) else {
            print("Cropping rectangle is beyond the image bounds")
            return nil
        }
        guard let buffer = UIImage(cgImage: cropped).pixelBuffer(
            width:  Int(rect.width),
            height: Int(rect.height)) else {
                fatalError()
        }
        return Patch(buffer: buffer,
                     position: (Int(rect.origin.x), Int(rect.origin.y)),
                     size: (Int(rect.width), Int(rect.height)))
    }
    
    public var size: CGSize {
        get { return CGSize(width: width, height: height) }
    }
}
