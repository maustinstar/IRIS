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
    private var patchesRendered = 0
//    /**
//     Determines if edge patches should crop the inset.
//     */
//    public var shouldCropBorders = false
    
    private let model = IRISCNN2()
    
    struct Patch {
        static var size = 200
        let buffer: CVPixelBuffer
        let position: CGPoint
        
        init(buffer: CVPixelBuffer, position: CGPoint) {
            self.buffer = buffer
            self.position = position
        }
        
        init(buffer: MLMultiArray, position: CGPoint) {
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
    }
    
    private func decomposePatch(from image: CGImage, at postition: CGPoint) -> Patch {
        
        var rect = CGRect(
            origin: CGPoint(
                x: Int(postition.x) * (Patch.size - horizontalPatchInset * 2),
                y: Int(postition.y) * (Patch.size - verticalPatchInset * 2)),
            size: CGSize(
                width: Patch.size,
                height: Patch.size))
        
        // Account for rounding insets that do not add to image size
        if  rect.origin.x > CGFloat(image.width - Patch.size + horizontalPatchInset) {
            rect.origin.x = CGFloat(image.width - Patch.size + horizontalPatchInset)
        }
        
        if  rect.origin.y > CGFloat(image.height - Patch.size + verticalPatchInset) {
            rect.origin.y = CGFloat(image.height - Patch.size + verticalPatchInset)
        }
        
        guard let cropped = image.cropping(to: rect) else {
            fatalError()
        }
        guard let buffer = UIImage(cgImage: cropped).pixelBuffer(width: Patch.size, height: Patch.size) else {
            fatalError()
        }
        return Patch(buffer: buffer, position: rect.origin)
    }
    
    private func predict(_ patchIn: Patch) -> Patch {
        do {
            let res = try model.prediction(image: patchIn.buffer)
            return Patch(buffer: res.output1, position: patchIn.position)
        } catch {
            fatalError()
        }
    }
    
    private func infer(src: CGImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        let maxX = Int(ceil(Double(src.width) / Double(Patch.size - minimumPatchInset * 2)))
        horizontalPatchInset = (200 - src.width / maxX)
        
        let maxY = Int(ceil(Double(src.height) / Double(Patch.size - minimumPatchInset * 2)))
        verticalPatchInset = (200 - src.height / maxY)
        
        totalPatches = maxX * maxY
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                // Estimate IRIS Patch
                let patchIn = self.decomposePatch(from: src, at: CGPoint(x: x, y: y))
                var patchOut = self.predict(patchIn)
                
                var rect = CGRect()
                var inset = CGRect()
                
                var (xPos, yPos) = (0, 0)
                var (rXPos, rYPos) = (Int(horizontalPatchInset),
                                      Int(verticalPatchInset))
                var (width, height) = (Patch.size - Int(horizontalPatchInset * 2),
                                       Patch.size - Int(verticalPatchInset * 2))
                
                if x == 0 {
                    width += Int(horizontalPatchInset)
                    rXPos = 0
                } else if x == maxX - 1 {
                    width += Int(horizontalPatchInset)
                    xPos = Int(patchOut.position.x) + Int(horizontalPatchInset)
                } else {
                    xPos = Int(patchOut.position.x) + Int(horizontalPatchInset)
                }
                
                if y == 0 {
                    height += Int(verticalPatchInset)
                    rYPos = 0
                } else if y == maxY - 1 {
                    height += Int(verticalPatchInset)
                    yPos = Int(patchOut.position.y) + Int(verticalPatchInset)
                } else {
                    yPos = Int(patchOut.position.y) + Int(verticalPatchInset)
                }
                
                // Rect within full image to render the patch
                rect = CGRect(
                    x: xPos,
                    y: yPos,
                    width:  (x != maxX - 1) ? width : Int(size.width) - xPos,
                    height: (y != maxY - 1) ? height : Int(size.height) - yPos)
                
                // segment of patch to render (remove insets)
                inset = CGRect(
                    x: rXPos,
                    y: rYPos,
                    width:  width,
                    height: height)
                
                let image = patchOut.cgImage
                
                guard let cropped = image!.cropping(to: inset) else {
                    fatalError()
                }
                // Add image to current context
                UIImage(cgImage: cropped).draw(in: rect)
                patchesRendered += 1
                print(progress)
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func estimate(_ src: UIImage) -> UIImage? {
        let t = Date()
        let resized = src.scaled()!.cgImage!
        
        let size = CGSize(width: resized.width, height: resized.height)
        let res = infer(src: resized, size: size)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t)) seconds.")
        return res
        
    }
}
