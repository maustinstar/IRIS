//
//  ImageCell.swift
//  BottomSheet
//
//  Created by Michael Verges on 10/26/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageFrame: UIView!
    
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                imageFrame.layer.borderColor = UIColor.yellow.cgColor
                imageFrame.layer.cornerRadius = 18
                imageFrame.layer.borderWidth = 4
            default:
                imageFrame.layer.borderWidth = 0
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
    
    public func startAnimating(easeIn duration: TimeInterval = 0.4) {
        self.effectView.alpha = 1.0
        indicator.startAnimating()
    }
    
    public func stopAnimating() {
        self.effectView.alpha = 0.0
        indicator.stopAnimating()
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        imageFrame.layer.mask = maskLayer
    }
}
