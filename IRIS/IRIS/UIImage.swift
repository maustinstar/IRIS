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
    
    func reoriented() -> UIImage {
        if self.imageOrientation == .up { return self }
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
    
//    func flipVertically() -> UIImage {
//        var newOrient:UIImage.Orientation
//        switch imageOrientation {
//        case .up:
//            newOrient = .downMirrored
//        case .upMirrored:
//            newOrient = .down
//        case .down:
//            newOrient = .upMirrored
//        case .downMirrored:
//            newOrient = .up
//        case .left:
//            newOrient = .leftMirrored
//        case .leftMirrored:
//            newOrient = .left
//        case .right:
//            newOrient = .rightMirrored
//        case .rightMirrored:
//            newOrient = .right
//        }
//        return UIImage(CGImage: self.cgImage!, scale: self.scale, orientation: newOrient)
//    }
//    
//    func flipHorizontally() -> UIImage {
//        var newOrient:UIImage.Orientation
//        switch imageOrientation {
//        case .Up:
//            newOrient = .DownMirrored
//        case .UpMirrored:
//            newOrient = .Down
//        case .Down:
//            newOrient = .UpMirrored
//        case .DownMirrored:
//            newOrient = .Up
//        case .Left:
//            newOrient = .LeftMirrored
//        case .LeftMirrored:
//            newOrient = .Left
//        case .Right:
//            newOrient = .RightMirrored
//        case .RightMirrored:
//            newOrient = .Right
//        }
//        return UIImage(CGImage: self.cgImage, scale: self.scale, orientation: newOrient)
//    }
}
