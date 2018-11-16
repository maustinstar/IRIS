//
//  PhotoEditingViewController.swift
//  IRIS Extension
//
//  Created by Michael Verges on 10/20/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import IRIS

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    @IBOutlet weak var preview: UIImageView!
    
    lazy var transferModel: ImageTransfer = {
        return ImageTransfer()
    }()
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        transferModel.requestTransferFrom(
        UIImage(contentsOfFile: input!.fullSizeImageURL!.path)!) { (output) in
            self.preview.image = output
        }
        indicator.hidesWhenStopped = true
        self.preview.contentMode = .scaleAspectFit
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        
        // Update UI to reflect that editing has finished and output is being rendered.
        // Render and provide output on a background queue.
        
        let contentEditingOutput = PHContentEditingOutput(contentEditingInput: self.input!)
        do {
            let archiveData = try NSKeyedArchiver.archivedData(withRootObject: "Boost Resolution", requiringSecureCoding: false)
            let identifier = "com.iris.app-extension.boost-res"
            let adjustmentData = PHAdjustmentData(formatIdentifier: identifier, formatVersion: "1.0", data: archiveData)
            contentEditingOutput.adjustmentData = adjustmentData
        } catch {
            fatalError("Can not archive data.")
        }
        if let image = self.preview.image {
            let jpegData = image.jpegData(compressionQuality: 1.0)
            
            do {
                try jpegData?.write(to: contentEditingOutput.renderedContentURL, options: .atomic)
                completionHandler(contentEditingOutput)
            } catch {
                print("Save error")
                completionHandler(nil)
            }
        } else {
            print("Load error")
            completionHandler(nil)
        }
    }
    
    var shouldShowCancelConfirmation: Bool = false
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
}
