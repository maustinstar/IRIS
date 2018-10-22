//
//  IRISEstimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

class IRISEstimator {
    /**
     The minimum number of pixels to overlap image patches.
     - note: Higher insets can increase data consistency in the final render but increases computation load
     - note: Better trained models can work with lower insets.
     */
    public let minimumPatchInset: CGFloat      = 0
    private var horizontalPatchInset: CGFloat   = 0
    private var verticalPatchInset: CGFloat     = 0
//    /**
//     Determines if edge patches should crop the inset.
//     */
//    public var shouldCropBorders = false
    
    private let predictionQueue = OperationQueue()
    
    private let model = IRISCNN2()
    
    private let shrinkSize = 0
    
    struct PatchIn {
        static var size = 200
        let buffer: CVPixelBuffer
        let position: CGPoint
    }
    
    struct PatchOut {
        static var size = 200
        let buffer: MLMultiArray
        let position: CGPoint
    }
    
    private func decomposePatch(from image: CGImage, at postition: CGPoint) -> PatchIn {
        
        let rect = CGRect(
            origin: CGPoint(
                x: postition.x * (CGFloat(PatchOut.size) - horizontalPatchInset),
                y: postition.y * (CGFloat(PatchOut.size) - verticalPatchInset)),
            size: CGSize(
                width: PatchIn.size,
                height: PatchIn.size))
        
        guard let cropped = image.cropping(to: rect) else {
            fatalError()
        }
        guard let buffer = UIImage(cgImage: cropped).pixelBuffer(width: PatchIn.size, height: PatchIn.size) else {
            fatalError()
        }
        return PatchIn(buffer: buffer, position: rect.origin)
    }
    
    private func predict(_ patchIn: PatchIn) -> PatchOut {
        do {
            let res = try model.prediction(image: patchIn.buffer)
            return PatchOut(buffer: res.output1, position: patchIn.position)
        } catch {
            fatalError()
        }
    }
    
    private func infer(src: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        
        
        guard let cgimage = src.cgImage else {
            return nil
        }
        
        let maxY: Int = Int(src.size.height) / (PatchOut.size - Int(verticalPatchInset))
        let maxX: Int = Int(src.size.width) / (PatchOut.size - Int(horizontalPatchInset))
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                
                
                // Estimate IRIS Patch
                let patchIn = self.decomposePatch(from: cgimage, at: CGPoint(x: x, y: y))
                let patchOut = self.predict(patchIn)
                
                var rect = CGRect()
                var inset = CGRect()
                
                var (xPos, yPos) = (0, 0)
                var (rXPos, rYPos) = (Int(horizontalPatchInset / 2),
                                      Int(verticalPatchInset / 2))
                var (width, height) = (PatchOut.size - Int(horizontalPatchInset),
                                       PatchOut.size - Int(verticalPatchInset))
                
                if x == 0 {
                    width += Int(horizontalPatchInset / 2)
                    rXPos = 0
                } else if x == maxX - 1 {
                    width += Int(horizontalPatchInset / 2)
                    xPos = Int(patchOut.position.x) + Int(horizontalPatchInset / 2)
                } else {
                    xPos = Int(patchOut.position.x) + Int(horizontalPatchInset / 2)
                }
                
                if y == 0 {
                    height += Int(verticalPatchInset / 2)
                    rYPos = 0
                } else if y == maxY - 1 {
                    height += Int(verticalPatchInset / 2)
                    yPos = Int(patchOut.position.y) + Int(verticalPatchInset / 2)
                } else {
                    yPos = Int(patchOut.position.y) + Int(verticalPatchInset / 2)
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
                
                let image = patchOut.buffer.image(offset: 0, scale: 255)?.cgImage
                
                guard let cropped = image!.cropping(to: inset) else {
                    fatalError()
                }
                // Add image to current context
                UIImage(cgImage: cropped).draw(in: rect)
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func estimate(_ src: UIImage) -> UIImage? {
        let t = Date()
        print("beginning")
        let resized = src.scaled()!
        
        let x = Int(ceil(CGFloat((resized.cgImage?.width)!) / (CGFloat(PatchOut.size) - minimumPatchInset)))
        horizontalPatchInset = CGFloat(200 - resized.cgImage!.width / x)
        
        let y = Int(ceil(CGFloat((resized.cgImage?.height)!) / (CGFloat(PatchOut.size) - minimumPatchInset)))
        verticalPatchInset = CGFloat(200 - resized.cgImage!.height / y)
        
        let size = resized.size
        let res = infer(src: resized, size: size)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t))")
        return res
        
    }
}
