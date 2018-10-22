//
//  IRISEstimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation
import VideoToolbox

class IRISEstimator {
    /**
     The minimum number of pixels to overlap image patches.
     - note: Higher insets can increase data consistency in the final render but increases computation load
     - note: Better trained models can work with lower insets.
     */
    public  let minimumPatchInset:    Int = 4 // increase this
    private var horizontalPatchInset: Int = 0
    private var verticalPatchInset:   Int = 0
    
    public var progress: Double {
        get { return Double(patchesRendered) / Double(totalPatches) }
    }
    private var totalPatches = 1
    private var patchesRendered = 0 {
        didSet { print(progress) }
    }
//    /**
//     Determines if edge patches should crop the inset.
//     */
//    public var shouldCropBorders = false
    
    private let model = IRISCNN2()
    
    struct Patch {
        static var size = 200
        let buffer: CVPixelBuffer
        let position: (Int, Int)
        
        init(buffer: CVPixelBuffer, position: (Int, Int)) {
            self.buffer = buffer
            self.position = position
        }
        
        init(buffer: MLMultiArray, position: (Int, Int)) {
            self.buffer = (buffer.image(offset: 0, scale: 255)!.pixelBuffer(
                    width: IRISEstimator.Patch.size,
                    height: IRISEstimator.Patch.size))!
            self.position = position
        }
        
        lazy var cgImage: CGImage? = {
            var image: CGImage?
            VTCreateCGImageFromCVPixelBuffer(self.buffer, options: nil, imageOut: &image)
            return image
        }()
        
        lazy var x: Int = { return position.0 }()
        lazy var y: Int = { return position.1 }()
    }
    
    private func decomposePatch(from image: CGImage, at postition: (Int, Int)) -> Patch {
        
        var rect = CGRect(
            origin: CGPoint(
                x: Int(postition.0) * (Patch.size - horizontalPatchInset * 2),
                y: Int(postition.1) * (Patch.size - verticalPatchInset * 2)),
            size: CGSize(
                width: Patch.size,
                height: Patch.size))
        
        // Account for rounding insets that do not add to image size
        if  rect.origin.x > CGFloat(image.width - Patch.size) {
            rect.origin.x = CGFloat(image.width - Patch.size)
        }
        
        if  rect.origin.y > CGFloat(image.height - Patch.size) {
            rect.origin.y = CGFloat(image.height - Patch.size)
        }
        
        guard let cropped = image.cropping(to: rect) else {
            fatalError()
        }
        guard let buffer = UIImage(cgImage: cropped).pixelBuffer(width: Patch.size, height: Patch.size) else {
            fatalError()
        }
        return Patch(buffer: buffer, position: (Int(rect.origin.x), Int(rect.origin.y)))
    }
    
    private func predict(_ patchIn: Patch) -> Patch {
        do {
            let res = try model.prediction(image: patchIn.buffer)
            return Patch(buffer: res.output1, position: patchIn.position)
        } catch {
            fatalError()
        }
    }
    
    private func infer(image: CGImage) -> UIImage? {
        let size = CGSize(width: image.width, height: image.height)
        UIGraphicsBeginImageContext(size)
        
        let maxX = Int(ceil(Double(image.width) / Double(Patch.size - minimumPatchInset * 2)))
        horizontalPatchInset = Int((Double(Patch.size) - Double(image.width) / Double(maxX)) / 2)
        
        let maxY = Int(ceil(Double(image.height) / Double(Patch.size - minimumPatchInset * 2)))
        verticalPatchInset = Int((Double(Patch.size) - Double(image.height) / Double(maxY)) / 2)
        
        totalPatches = maxX * maxY
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                // Estimate IRIS Patch
                let patchIn = self.decomposePatch(from: image, at: (x: x, y: y))
                var patchOut = self.predict(patchIn)
                
                var rect = CGRect()
                var inset = CGRect()
                
                var drawPosition = (Int(patchOut.x) + Int(horizontalPatchInset),
                                    Int(patchOut.y) + Int(verticalPatchInset))
                var renderInset = (horizontalPatchInset, verticalPatchInset)
                var (width, height) = (Patch.size - Int(horizontalPatchInset * 2),
                                       Patch.size - Int(verticalPatchInset * 2))
                
                if x == 0 {
                    width += Int(horizontalPatchInset)
                    renderInset.0 = 0
                    drawPosition.0 = 0
                } else if x == maxX - 1 {
                    width += Int(horizontalPatchInset)
                }
                
                if y == 0 {
                    height += Int(verticalPatchInset)
                    renderInset.1 = 0
                    drawPosition.1 = 0
                } else if y == maxY - 1 {
                    height += Int(verticalPatchInset)
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
