//
//  Patch.swift
//  IRIS
//
//  Created by Michael Verges on 10/23/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import VideoToolbox

struct Patch {
    let buffer: CVPixelBuffer
    
    let position: (Int, Int)
    var x: Int { get {return position.0} }
    var y: Int { get {return position.1} }
    
    let size: (Int, Int)
    var width:  Int { get {return size.0} }
    var height: Int { get {return size.1} }
    
    
    init(buffer: CVPixelBuffer, position: (Int, Int), size: (Int, Int)) {
        self.position = position
        self.size = size
        self.buffer = buffer
    }
    
    init(buffer: MLMultiArray, position: (Int, Int), size: (Int, Int)) {
        self.position = position
        self.size = size
        self.buffer = (buffer.image(offset: 0, scale: 255)!
            .pixelBuffer(width: size.0, height: size.1))!
    }
    
    var cgImage: CGImage? {
        get {
            var image: CGImage?
            VTCreateCGImageFromCVPixelBuffer(self.buffer, options: nil, imageOut: &image)
            return image
        }
    }
    
    var uiImage: UIImage? {
        get {
            guard let cgImage = cgImage else { return nil }
            return UIImage(cgImage: cgImage)
        }
    }
}
