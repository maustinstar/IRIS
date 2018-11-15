//
//  ImageCell.swift
//  BottomSheet
//
//  Created by Michael Verges on 10/26/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import IRIS

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageFrame: UIView!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var progressView: UIProgressView!
    var delegate: ImageCellDelegate?
    
    private lazy var transferModel: ImageTransfer = {
        return ImageTransfer.main
    }()
    
    var progress: CGFloat = 0.0 {
        didSet {
            progressView.progress = Float(progress)
        }
    }
    
    public var sourceImage: UIImage? {
        didSet {
            imageView.image = sourceImage
        }
    }
    
    public var transferImage: UIImage? {
        didSet {
            delegate?.didTransferImage(cell: self, image: transferImage)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                // update UI
                break
            default:
                // update UI
                break
            }
        }
    }
    
    private lazy var maskLayer: CAShapeLayer = {
        let radius = CGSize(width: 20, height: 20)
        
        let path = UIBezierPath(
            roundedRect:        view.bounds,
            byRoundingCorners:  .allCorners,
            cornerRadii:        radius)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        
        return layer
    }()
    
    public func requestTransferImage() {
        
        if transferImage != nil {
            delegate?.didTransferImage(cell: self, image: transferImage)
        } else {
            guard let sourceImage = sourceImage else {
                fatalError("Invalid Source Image")
            }
            transferModel.delegate = self
            transferModel.requestTransferFrom(sourceImage, completion: { (output) in
                self.transferImage = output
            })
        }
    }
    
    public func startAnimating(easeIn duration: TimeInterval = 0.4) {
        self.effectView.alpha = 1.0
    }
    
    public func stopAnimating() {
        self.effectView.alpha = 0.0
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        imageFrame.layer.mask = maskLayer
    }
}

extension ImageCell: ImageTransferDelegate {
    func imageTransferDidSet(progress: CGFloat) {
        self.progress = progress
    }
}
