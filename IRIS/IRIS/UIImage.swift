//
//  UIImage.swift
//  IRIS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

public extension UIImage {
    
    /// - returns: `UIImage` with dimenstions scaled @2x
//    public func enhance() -> UIImage? {
//        
//        return ImageTransfer.main.estimate(self)
//    }
    
    /**
     Duplicates pixels to scale the image without quaility change
     - returns: `UIImage` with dimenstions scaled @2x
     */
    public func scaled() -> UIImage? {
        let newSize = CGSize(width: size.width * 2, height: size.height * 2)
        UIGraphicsBeginImageContext(newSize) // 170.8 MB
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.interpolationQuality = CGInterpolationQuality.high
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height))
        ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
