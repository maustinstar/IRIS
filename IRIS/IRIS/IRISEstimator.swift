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
    
    struct PatchIn {
        static var size = 200
        let buff: CVPixelBuffer
        let position: CGPoint
    }
    
    struct PatchOut {
        static var size = 200
        let buff: MLMultiArray
        let position: CGPoint
    }
    
    private func decomposePatch(from image: CGImage, at postition: CGPoint) -> PatchIn {
        
        let rect = CGRect(origin: CGPoint(x: Int(postition.x) * PatchOut.size, y: Int(postition.y) * PatchOut.size), size: CGSize(width: PatchIn.size, height: PatchIn.size))
        guard let cropped = image.cropping(to: rect) else {
            fatalError()
        }
        guard let buff = UIImage(cgImage: cropped).pixelBuffer(width: PatchIn.size, height: PatchIn.size) else {
            fatalError()
        }
        return PatchIn(buff: buff, position: postition)
    }
    
    private func predict(_ patchIn: PatchIn) -> PatchOut {
        do {
            let res = try model.prediction(image: patchIn.buff)
            return PatchOut(buff: res.output1, position: patchIn.position)
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
                // Analyze individual patch
//                let t = Date()
                let patchIn = self.decomposePatch(from: cgimage, at: CGPoint(x: x, y: y))
//                let t2 = Date()
//                print("Decomposing patch", x , y, ":", t2.timeIntervalSince(t))
                
                // Estimate IRIS Patch
                let patchOut = self.predict(patchIn)
//                let t3 = Date()
//                print("Predicting patch ", x , y, ":", t3.timeIntervalSince(t2))
                
                // Render IRIS Patch
                let position = patchOut.position
                let image = patchOut.buff.image(offset: 0, scale: 255)!
                
//                let t4 = Date()
//                print("Buffering patch ", x , y, ":", t4.timeIntervalSince(t3))
                
                let rect = CGRect(x: position.x * CGFloat(PatchOut.size), y: position.y * CGFloat(PatchOut.size), width: CGFloat(PatchOut.size), height: CGFloat(PatchOut.size))
                image.draw(in: rect)
//                let t5 = Date()
//                print("Rendering patch  ", x , y, ":", t5.timeIntervalSince(t4))
//                print("Total            ", x , y, ":", t5.timeIntervalSince(t))
            }
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func estimate(_ src: UIImage) -> UIImage? {
        let t = Date()
        print("beginning")
        let resized = src.scaled()!
        let res =  infer(src: resized, size: resized.size)!
        
        let t2 = Date()
        print("done in: \(t2.timeIntervalSince(t))")
        return res
        
    }
}
