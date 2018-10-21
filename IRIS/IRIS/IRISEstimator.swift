//
//  IRISEstimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

class IRISEstimator {
    
    private let minimumPatchInset: CGFloat = 12.0
    private var horizontalPatchInset: CGFloat = 12.0
    private var verticalPatchInset: CGFloat = 12.0
    
    private let predictionQueue = OperationQueue()
    
    private let model = IRISCNN2() // dummy model. Replace with IRISCNN()
    
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
                x: postition.x * CGFloat(PatchOut.size) - (postition.x * horizontalPatchInset),
                y: postition.y * CGFloat(PatchOut.size) - (postition.y * verticalPatchInset)),
            size: CGSize(width: PatchIn.size, height: PatchIn.size))
        
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
            let res = try model.prediction(image: patchIn.buffer) // 20+ MB!
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
                
                
                // Rect within full image to render the patch
                let rect = CGRect(
                    x: Int(patchOut.position.x) - Int(horizontalPatchInset / 2),
                    y: Int(patchOut.position.y) - Int(verticalPatchInset / 2),
                    width:  PatchOut.size - Int(horizontalPatchInset),
                    height: PatchOut.size - Int(verticalPatchInset))
                
                // segment of patch to render (remove borders)
                let inset = CGRect(
                    x: horizontalPatchInset * 0.5,
                    y: verticalPatchInset * 0.5,
                    width:  CGFloat(PatchOut.size) - horizontalPatchInset,
                    height: CGFloat(PatchOut.size) - verticalPatchInset)
                
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
        
        let size = CGSize(
            width: x * Int(200 - horizontalPatchInset) - Int(horizontalPatchInset),
            height: y * Int(200 - verticalPatchInset) - Int(verticalPatchInset))
        let res = infer(src: resized, size: size)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t))")
        return res
        
    }
}
