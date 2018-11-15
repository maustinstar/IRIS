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
        let height = view.frame.height
        let width  = view.frame.width
        drawer.view.frame = CGRect(
            x:      0,
            y:      self.view.frame.maxY,
            width:  width,
            height: height)
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
        
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        imageView.addGestureRecognizer(gestureRecognizer)
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
                UIView.animate(withDuration: 0.2) {
                    self.view.backgroundColor = .black
                }
            case false:
                drawer.show()
                UIView.animate(withDuration: 0.2) {
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
