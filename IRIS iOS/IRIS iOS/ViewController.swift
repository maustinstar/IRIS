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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var button: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var sourceImage: UIImage?
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        
        switch sourceImage {
        case nil:
            selectImage(sender: sender)
        default:
            enhanceSource()
        }
        
        switch sourceImage {
        case nil:
            button.setTitle("Select Photo", for: .normal)
        default:
            button.setTitle("Enhance", for: .normal)
        }
        
    }
    
    func selectImage(sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Browse...", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.indicator.stopAnimating()
        self.button.setTitle("Select Photo", for: .normal)
        
        switch sourceImage {
        case nil:
            button.setTitle("Select Photo", for: .normal)
        default:
            button.setTitle("Enhance", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.stopAnimating()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        indicator.hidesWhenStopped = true
        
        switch sourceImage {
        case nil:
            button.setTitle("Select Photo", for: .normal)
        default:
            button.setTitle("Enhance", for: .normal)
        }
    }
    
    func enhanceSource() {
        // update UI
        button.setTitle("Select Photo", for: .normal)
//        indicator.startAnimating()
        
        DispatchQueue.global().async {
            // export poto
            // enhance
            let new = self.sourceImage!.enhance()!
            
            // save
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: new)
            }, completionHandler: nil)
            self.sourceImage = nil
            UIApplication.shared.open(URL(string:"photos-redirect://")!)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // Set yourImageView to display the selected image.
        sourceImage = selectedImage
        button.setTitle("Enhance", for: .normal)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}

