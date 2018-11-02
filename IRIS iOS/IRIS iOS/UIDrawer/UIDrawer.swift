//
//  UIDrawer.swift
//  IRIS
//
//  Created by Michael Verges on 10/26/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class UIDrawer: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
    
    var delegate: UIDrawerDelegate?
    
    var selectedImage: UIImage? {
        didSet {
            delegate?.drawerDidSelect(image: selectedImage)
        }
    }
    
    // Photo data sources
    
    lazy var recentPhotos: PhotoDataSource = {
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return PhotoDataSource(collectionView: collectionView, withOptions: options)
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let radius = CGSize(width: 40, height: 40)
        
        let path = UIBezierPath(
            roundedRect:        view.bounds,
            byRoundingCorners:  [.topLeft, .topRight],
            cornerRadii:        radius)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        
        return layer
    }()
    
    public var expandedHeight: CGFloat  = UIScreen.main.bounds.height - 100
    public var minimizedHeight: CGFloat = 212
    
    private var fullView: CGFloat {
        return UIScreen.main.bounds.height - expandedHeight
    }
    private var partialView: CGFloat {
        return UIScreen.main.bounds.height - minimizedHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = recentPhotos
        collectionView.register(UINib(nibName: "ImageCell", bundle: Bundle.main), forCellWithReuseIdentifier: "image")
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(UIDrawer.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentView.layer.mask = maskLayer
        //        view.layer.addSublayer(maskLayer)
        
        view.layer.shadowColor   = UIColor.black.cgColor
        view.layer.shadowPath    = maskLayer.path!
        view.layer.shadowOffset  = CGSize(width: 0, height: 0)
        view.layer.shadowRadius  = 60
        view.layer.shadowOpacity = 0.2
        
        show(withDuration: 0.6)
    }
    
    func hide(withDuration duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.frame.origin.y = UIScreen.main.bounds.height
        })
    }
    
    func show(withDuration duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            let yComponent = self?.partialView
            self?.view.frame.origin.y = yComponent!
//            self?.view.frame.size.height = (self?.fullView)!
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setY(
        _ height: CGFloat,
        withVelocity velocity: CGPoint = CGPoint(x: 0, y: 0.5),
        completion: ((Bool) -> Void)? = nil
        ) {
        UIView.animate(
            withDuration: min(1.3, Double((height - self.view.frame.minY) /  velocity.y)),
            delay:      0.0,
            options:    [.allowUserInteraction],
            animations: { self.view.frame.origin.y = height },
            completion: completion)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        // pan in progress
        let translation = recognizer.translation(in: self.view)
        let y = self.view.frame.minY + translation.y
        if (y >= fullView) && (y <= partialView) {
            self.view.frame.origin.y = y
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        // pan ended
        if recognizer.state == .ended {
            feedbackGenerator.prepare()
            let velocity = recognizer.velocity(in: self.view)
            if  velocity.y >= 0 {
                setY(partialView, withVelocity: velocity) { _ in
                    self.feedbackGenerator.impactOccurred()
                }
            } else {
                setY(fullView, withVelocity: velocity) { _ in
                    self.feedbackGenerator.impactOccurred()
                }
            }
        }
    }
}

extension UIDrawer: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

extension UIDrawer: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let asset = (collectionView.dataSource as? PhotoDataSource)?
            .photos?.object(at: indexPath.row) else {
                return
        }
        
        (collectionView.cellForItem(at: indexPath) as! ImageCell).startAnimating()
        PHImageManager.default().requestImageData(for: asset, options: nil) { (data, string, orientation, _) in
            self.selectedImage = UIImage(data: data!)?.enhance()
            
            DispatchQueue.main.async {
                (self.collectionView.cellForItem(at: indexPath) as! ImageCell).stopAnimating()
            }
        }
    }
}
