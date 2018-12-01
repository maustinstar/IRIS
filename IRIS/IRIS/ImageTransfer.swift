//
//  Estimator.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation
import VideoToolbox

public class ImageTransfer: PatchDelegate {
    
    var completion: ((UIImage) -> Void)?
    
    func didTransferPatch(_ patch: Patch) {
        render(patch, in: renderContext!)
        patchesRendered += 1
//        print(progress)
    }
    
    public var isCanceled = false
    public func cancel() { isCanceled = true }
    
    public static let main = ImageTransfer()
    
    public var delegate: ImageTransferDelegate?
    
    internal var model: Model
    
    
    //: Default ImageTransfer
    public init() {
        self.model = DSRCNN()
        ImageTransfer.Inset.minimum = 4
    }
    
    public init(model: Model, minimumOverlap: Int = 0) {
        self.model = model
        ImageTransfer.Inset.minimum = minimumOverlap
    }
    
    struct Inset {
        static var minimum    = 0
        static var horizontal = 0
        static var vertical   = 0
    }
    
    public var progress: CGFloat {
        get { return CGFloat(patchesRendered) / CGFloat(Patches.total) }
    }
    
    private var patchesRendered = 0 {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.imageTransferDidSet(progress: self.progress)
            }
            if patchesRendered == Patches.total && completion != nil {
                DispatchQueue.main.async {
                    let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    self.completion!(outputImage)
                }
            }
        }
    }
    
    struct Patches {
        static var x = 0
        static var y = 0
        static var total: Int { return x * y }
    }
    
    private var inputImage: UIImage?
    private var outputImageSize: CGSize? {
        return CGSize(width:  Int(inputImage!.size.width) * model.scaleFactor,
                      height: Int(inputImage!.size.height) * model.scaleFactor)
    }
    
    var renderContext: CGContext?
    private func render(_ patch: Patch, in context: CGContext) {
        
        let position = (
            (patch.index.0 != 0) ? patch.x + Inset.horizontal * model.scaleFactor : 0,
            (patch.index.1 != 0) ? patch.y + Inset.vertical   * model.scaleFactor : 0
        )
        
        // Inset of patch to render
        let patchInset = (
            (patch.index.0 != 0) ? Inset.horizontal * model.scaleFactor: 0,
            (patch.index.1 != 0) ? Inset.vertical   * model.scaleFactor: 0
        )
        
        // Size of patch to render
        let (width, height) = (
            (patch.index.0 == 0 || patch.index.0 == Patches.x - 1)
                ? patch.width - Int(Inset.horizontal * model.scaleFactor)
                : patch.width - Int(Inset.horizontal * model.scaleFactor * 2),
            (patch.index.1 == 0 || patch.index.1 == Patches.y - 1)
                ? patch.height - Int(Inset.vertical * model.scaleFactor)
                : patch.height - Int(Inset.vertical * model.scaleFactor * 2)
        )
        
        // Rect within full image to render the patch
        let rect = CGRect(x: position.0, y: position.1, width: width, height: height)
        
        // segment of patch to render (remove insets)
        let inset = CGRect(x: patchInset.0, y: patchInset.1, width: width, height: height)
        
        let patchImage = patch.cgImage
        
        guard let croppedImage = patchImage!.cropping(to: inset) else {
            fatalError("Patch can not be rendered")
        }
        // Add image to render context
        UIGraphicsPushContext(renderContext!)
        UIImage(cgImage: croppedImage).draw(in: rect)
//        renderContext?.draw(croppedImage, in: rect) // renders flipped?
    }
    
    private func patch(from image: CGImage, at postition: (Int, Int)) -> Patch {
        
        // Account for rounding insets that do not add to image size
        let x = min(
            postition.0 * (model.inputWidth - Inset.horizontal * 2),
            image.width - model.inputWidth)
        
        let y = min(
            postition.1 * (model.inputHeight - Inset.vertical * 2),
            image.height - model.inputHeight)
        
        let rect = CGRect(
            origin: CGPoint(x: x, y: y),
            size: CGSize(width: model.inputWidth, height: model.inputHeight))
        let patch = image.patch(in: rect, at: postition)!
        return patch
    }
    
    private func infer(image: CGImage) {
        
        UIGraphicsBeginImageContext(outputImageSize!)
        renderContext = UIGraphicsGetCurrentContext()
        
        Patches.x = Int(ceil(Double(image.width)  / Double(model.inputWidth  - Inset.minimum * 2)))
        Patches.y = Int(ceil(Double(image.height) / Double(model.inputHeight - Inset.minimum * 2)))
        
        Inset.horizontal = Int((Double(model.inputWidth)  - Double(image.width)  / Double(Patches.x)) / 2)
        Inset.vertical   = Int((Double(model.inputHeight) - Double(image.height) / Double(Patches.y)) / 2)
        
        for x in 0..<Patches.x {
            for y in 0..<Patches.y {
                if isCanceled { return }
                let p = patch(from: image, at: (x: x, y: y))
                p.delegate = self
                p.transfer(withModel: model)
            }
        }
    }
    
    public func requestTransferFrom(_ image: UIImage, completion: ((UIImage) -> Void)? = nil) {
        isCanceled = false
        patchesRendered = 0
        self.completion = completion
        var resized = image.reoriented()
        if model.scaleFactor == 1 {
            resized = resized.scaled()!
        }
        self.inputImage = resized
        
        infer(image: resized.cgImage!)
    }
}
