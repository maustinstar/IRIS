//
//  ViewController.swift
//  IRIS iOS
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import IRIS
import Photos

class ViewController: UIViewController, UIDrawerDelegate {
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var transferImage: UIImage?
    var originalImage: UIImage?
    
    @IBOutlet weak var tag: UILabel!
    
    var isPreviewingOriginal: Bool = false {
        didSet {
            switch isPreviewingOriginal {
            case true:
                imageView.image = originalImage
                tag.isHidden = false
            default:
                imageView.image = transferImage
                tag.isHidden = true
            }
        }
    }
    
    @objc func zoom(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(
                to: zoomRectForScale(
                    scale: scrollView.maximumZoomScale,
                    center: recognizer.location(in: recognizer.view)),
                animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var rect = CGRect.zero
        rect.size.height = imageView.frame.size.height / scale
        rect.size.width  = imageView.frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: imageView)
        rect.origin.x = newCenter.x - (rect.size.width / 2.0)
        rect.origin.y = newCenter.y - (rect.size.height / 2.0)
        return rect
    }
    
    @IBAction func previewOriginal(_ sender: Any) {
        isPreviewingOriginal = true
    }
    
    @IBAction func exitPreview(_ sender: Any) {
        isPreviewingOriginal = false
    }
    
    @IBAction func save(_ sender: Any) {
        self.imageView.image.share()
    }
    
    lazy var drawer: UIDrawer = {
        let drawer = UIDrawer()
        drawer.delegate = self
        drawer.didMove(toParent: self)
        drawer.view.frame = container.frame
        return drawer
    }()
    
    func drawerDidSelect(image: UIImage?) {
        originalImage = image
    }
    
    func drawerDidTransfer(image: UIImage?) {
        transferImage = image
        imageView.image = transferImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layer.backgroundColor = UIColor.white.cgColor
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoom(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        singleTap.require(toFail: doubleTap)
        imageView.addGestureRecognizer(doubleTap)
        imageView.addGestureRecognizer(singleTap)
        imageView.isUserInteractionEnabled = true
        self.addChild(drawer)
        self.view.addSubview(drawer.view)
    }
    
    @objc func tapImage() {
        if isFocused {
            isFocused = false
        } else if imageView.image != nil {
            isFocused = true
        }
    }
    
    ///: A Boolean value indicating if the view is focused on the image
    var isFocused = false {
        didSet {
            switch isFocused {
            case true:
                drawer.hide()
                UIView.animate(withDuration: 0.15) {
                    self.view.backgroundColor = .black
                }
            case false:
                drawer.show()
                UIView.animate(withDuration: 0.15) {
                    self.view.backgroundColor = .white
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
