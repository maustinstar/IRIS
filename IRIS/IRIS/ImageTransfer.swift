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
        static var size: (Int, Int) { get {
            return (ImageTransfer.Input.width, ImageTransfer.Input.height)
        } }
    }
    
    struct Output {
        static var width  = 0
        static var height = 0
        static var size: (Int, Int) { get {
            return (ImageTransfer.Output.width, ImageTransfer.Output.height)
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
    
    private func patch(from image: CGImage, at postition: (Int, Int)) -> Patch {
        
        // Account for rounding insets that do not add to image size
        let x = min(
            postition.0 * (Input.width - Inset.horizontal * 2),
            image.width - Input.width)
        
        let y = min(
            postition.1 * (Input.height - Inset.vertical * 2),
            image.height - Input.height)
        
        let rect = CGRect(
            origin: CGPoint(x: x, y: y),
            size: CGSize(width: Input.width, height: Input.height))
        
        return image.patch(in: rect)!
    }
    
    private func predict(_ patch: Patch) -> Patch {
        do {
            let prediction = try model.prediction(image: patch.buffer)
            return Patch(buffer: prediction.output1, position: patch.position, size: Output.size)
        } catch {
            fatalError("Failed to predict from image buffer.")
        }
    }
    
    private func infer(image: CGImage) -> UIImage? {
        
        // Create blank image for the final render.
        UIGraphicsBeginImageContext(image.size)
        
        // Number of horizontal patches
        let maxX = Int(ceil(Double(image.width)  / Double(Input.width  - Inset.minimum * 2)))
        // Number of vertical patches
        let maxY = Int(ceil(Double(image.height) / Double(Input.height - Inset.minimum * 2)))
        // Number of total patches
        totalPatches = maxX * maxY
        
        Inset.horizontal = Int((Double(Input.width)  - Double(image.width)  / Double(maxX)) / 2)
        Inset.vertical   = Int((Double(Input.height) - Double(image.height) / Double(maxY)) / 2)
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                // Estimate IRIS Patch
                let patchOut = predict(patch(from: image, at: (x: x, y: y)))
                
                // Position in final image to draw the patch
                let position = (
                    (x != 0) ? patchOut.x + Inset.horizontal : 0,
                    (y != 0) ? patchOut.y + Inset.vertical   : 0
                )
                
                // Inset of patch to render
                let patchInset = (
                    (x != 0) ? Inset.horizontal : 0,
                    (y != 0) ? Inset.vertical   : 0
                )
                
                // Size of patch to render
                let (width, height) = (
                    (x == 0 || x == maxX - 1)
                        ? Output.width - Int(Inset.horizontal)
                        : Output.width - Int(Inset.horizontal * 2),
                    (y == 0 || y == maxY - 1)
                        ? Output.height - Int(Inset.vertical)
                        : Output.height - Int(Inset.vertical * 2)
                )
                
                // Rect within full image to render the patch
                let rect = CGRect(
                    x: position.0, y: position.1,
                    width: width, height: height)
                
                // segment of patch to render (remove insets)
                let inset = CGRect(
                    x: patchInset.0, y: patchInset.1,
                    width: width, height: height)
                
                let image = patchOut.cgImage
                
                guard let cropped = image!.cropping(to: inset) else {
                    fatalError("Patch can not be rendered")
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
