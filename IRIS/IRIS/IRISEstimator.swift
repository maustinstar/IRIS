//
//  IRISEstimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

class IRISEstimator {
    
    private let predictionQueue = OperationQueue()
    
    private let model = SRCNN() // dummy model. Replace with IRISCNN()
    
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
            origin: CGPoint(x: Int(postition.x) * PatchOut.size, y: Int(postition.y) * PatchOut.size),
            size: CGSize(width: PatchIn.size, height: PatchIn.size))
        guard let cropped = image.cropping(to: rect) else {
            fatalError()
        }
        guard let buffer = UIImage(cgImage: cropped).pixelBuffer(width: PatchIn.size, height: PatchIn.size) else {
            fatalError()
        }
        return PatchIn(buffer: buffer, position: postition)
    }
    
    private func expand(src: UIImage) -> UIImage? {
        let w = Int(src.size.width)
        let h = Int(src.size.height)
        let exW = w + shrinkSize * 2
        let exH = h + shrinkSize * 2
        let targetSize = CGSize(width: exW, height: exH)
        
        UIGraphicsBeginImageContext(targetSize) // 170.8 MB
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.black.cgColor)
        ctx.addRect(CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        ctx.drawPath(using: .fill)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: targetSize.height))
        ctx.draw(src.cgImage!, in: CGRect(x: shrinkSize, y: shrinkSize, width: w, height: h)) // 328.5 MB
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
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
        
        let maxY = Int(src.size.height) / PatchOut.size
        let maxX = Int(src.size.width) / PatchOut.size
        
        for y in 0..<maxY {
            for x in 0..<maxX {
                
                // Estimate IRIS Patch
                let patchIn = self.decomposePatch(from: cgimage, at: CGPoint(x: x, y: y))
                let patchOut = self.predict(patchIn)
                
                // Render Patch
                let rect = CGRect(
                    x: patchOut.position.x * CGFloat(PatchOut.size),
                    y: patchOut.position.y * CGFloat(PatchOut.size),
                    width:  CGFloat(PatchOut.size),
                    height: CGFloat(PatchOut.size))
                
                // Add image to current context
                patchOut.buffer.image(offset: 0, scale: 255)!.draw(in: rect)
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
        
//        guard let expanded = expand(src: resized) else {
//            return nil
//        }
        
        let size = CGSize(width: resized.size.width - (resized.size.width.truncatingRemainder(dividingBy: CGFloat(PatchOut.size))), height: resized.size.height - (resized.size.height.truncatingRemainder(dividingBy: CGFloat(PatchOut.size))))
        let res =  infer(src: resized, size: size)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t))")
        return res
        
    }
}
