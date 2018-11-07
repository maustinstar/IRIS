//
//  Model.swift
//  IRIS
//
//  Created by Michael Verges on 11/6/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

public protocol Model {
    func predict(image: CVPixelBuffer) throws -> MLMultiArray
//    func predict(image: CVPixelBuffer) throws -> CVPixelBuffer
    
    var inputSize: (Int, Int) { get }
    
    var inputWidth:  Int { get }
    var inputHeight: Int { get }
    
    var outputSize: (Int, Int) { get }
    var outputWidth:  Int { get }
    var outputHeight: Int { get }
    
    var scaleFactor: Int { get }
    
}

extension Model {
    
    var inputWidth:   Int { return inputSize.0 }
    var inputHeight:  Int { return inputSize.1 }
    var outputWidth:  Int { return inputWidth  * scaleFactor }
    var outputHeight: Int { return inputHeight * scaleFactor }
    var outputSize: (Int, Int) { return (outputWidth, outputHeight) }
    var scaleFactor:  Int { return 1 }
    
//    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
//        fatalError("Prediction as MLMultiArray not supported")
//    }
//    func predict(image: CVPixelBuffer) throws -> CVPixelBuffer {
//        fatalError("Prediction as CVPixelBuffer not supported")
//    }
}

extension IRISCNN: Model {
    
    var scaleFactor: Int { return 1 }
    var inputSize: (Int, Int) { return (200, 200) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}

extension IRISCNN2: Model {
    
    var scaleFactor: Int { return 1 }
    var inputSize: (Int, Int) { return (200, 200) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}

extension lightAsFlup: Model {
    
    var scaleFactor: Int { return 2 }
    var inputSize: (Int, Int) { return (256, 256) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}

extension lightAsFlupTheSequel: Model {
    
    var scaleFactor: Int { return 2 }
    var inputSize: (Int, Int) { return (256, 256) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}

extension lighterSRCNN16v2: Model {
    
    var scaleFactor: Int { return 2 }
    var inputSize: (Int, Int) { return (256, 256) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}

//extension StarryNight: Model {
//    
//    var scaleFactor: Int { return 1 }
//    var inputSize: (Int, Int) { return (720, 720) }
//    
//    func predict(image: CVPixelBuffer) throws -> CVPixelBuffer {
//        return try self.prediction(inputImage: image).outputImage
//    }
//}

extension TestConvT_1_1: Model {
    
    var scaleFactor: Int { return 2 }
    var inputSize: (Int, Int) { return (256, 256) }
    
    func predict(image: CVPixelBuffer) throws -> MLMultiArray {
        return try self.prediction(image: image).output1
    }
}
