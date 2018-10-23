//
//  Estimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation
import VideoToolbox

class ImageTransfer {
    
    private let model = IRISCNN2()
    
    init(minimumOverlap: Int = 0, inputSize: (Int, Int), outputSize: (Int, Int)) {
        ImageTransfer.Inset.minimum = minimumOverlap
        ImageTransfer.Input .width  = inputSize .0
        ImageTransfer.Input .height = inputSize .1
        ImageTransfer.Output.width  = outputSize.0
        ImageTransfer.Output.height = outputSize.1
    }
    
    struct Input {
        static var width  = 0
        static var height = 0
        var size: (Int, Int) { get {
            return (ImageTransfer.Input.width, ImageTransfer.Input.height)
        } }
    }
    
    struct Output {
        static var width  = 0
        static var height = 0
        var size: (Int, Int) { get {
            return (ImageTransfer.Input.width, ImageTransfer.Input.height)
        } }
    }
    
    struct Inset {
        static var minimum    = 0
        static var horizontal = 0
        static var vertical   = 0
    }
    
    public var progress: Double {
        get { return Double(patchesRendered) / Double(totalPatches) }
    }
    
    private var totalPatches = 1
    private var patchesRendered = 0
    
    private func decomposePatch(from image: CGImage, at postition: (Int, Int)) -> Patch {
        
        var rect = CGRect(
            origin: CGPoint(
                x: Int(postition.0) * (Input.width - Inset.horizontal * 2),
                y: Int(postition.1) * (Input.height - Inset.vertical * 2)),
            size: CGSize(width: Input.width, height: Input.height))
        
        // Account for rounding insets that do not add to image size
        if  rect.origin.x > CGFloat(image.width - Input.width) {
            rect.origin.x = CGFloat(image.width - Input.width)
        }
        
        if  rect.origin.y > CGFloat(image.height - Input.height) {
            rect.origin.y = CGFloat(image.height - Input.height)
        }
        
        return image.patch(in: rect)!
    }
    
    private func predict(_ patchIn: Patch) -> Patch {
        do {
            let res = try model.prediction(image: patchIn.buffer)
            return Patch(buffer: res.output1, position: patchIn.position, size: (Input.width, Input.height))
        } catch {
            fatalError()
        }
    }
    
    private func infer(image: CGImage) -> UIImage? {
        let size = CGSize(width: image.width, height: image.height)
        UIGraphicsBeginImageContext(size)
        
        let maxX = Int(ceil(Double(image.width) / Double(Input.width - Inset.minimum * 2)))
        Inset.horizontal = Int((Double(Input.width) - Double(image.width) / Double(maxX)) / 2)
        
        let maxY = Int(ceil(Double(image.height) / Double(Input.height - Inset.minimum * 2)))
        Inset.vertical = Int((Double(Input.height) - Double(image.height) / Double(maxY)) / 2)
        
        totalPatches = maxX * maxY
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                // Estimate IRIS Patch
                let patchIn = self.decomposePatch(from: image, at: (x: x, y: y))
                let patchOut = self.predict(patchIn)
                
                var rect = CGRect()
                var inset = CGRect()
                
                var drawPosition = (Int(patchOut.x) + Int(Inset.horizontal),
                                    Int(patchOut.y) + Int(Inset.vertical))
                var renderInset = (Inset.horizontal, Inset.vertical)
                var (width, height) = (Output.width - Int(Inset.horizontal * 2),
                                       Output.height - Int(Inset.vertical * 2))
                
                if x == 0 {
                    width += Int(Inset.horizontal)
                    renderInset.0 = 0
                    drawPosition.0 = 0
                } else if x == maxX - 1 {
                    width += Int(Inset.horizontal)
                }
                
                if y == 0 {
                    height += Int(Inset.vertical)
                    renderInset.1 = 0
                    drawPosition.1 = 0
                } else if y == maxY - 1 {
                    height += Int(Inset.vertical)
                }
                
                // Rect within full image to render the patch
                rect = CGRect(
                    x: drawPosition.0, y: drawPosition.1,
                    width: width, height: height)
                
                // segment of patch to render (remove insets)
                inset = CGRect(
                    x: renderInset.0, y: renderInset.1,
                    width: width, height: height)
                
                let image = patchOut.cgImage
                
                guard let cropped = image!.cropping(to: inset) else {
                    fatalError()
                }
                // Add image to current context
                UIImage(cgImage: cropped).draw(in: rect)
                patchesRendered += 1
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func estimate(_ src: UIImage) -> UIImage? {
        let t = Date()
        let resized = src.scaled()!.cgImage!
        
        let res = infer(image: resized)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t)) seconds.")
        return res
        
    }
}
