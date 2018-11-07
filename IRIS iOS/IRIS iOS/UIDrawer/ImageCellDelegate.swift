//
//  ImageCellDelegate.swift
//  IRIS iOS
//
//  Created by Michael Verges on 11/6/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import UIKit

protocol ImageCellDelegate {
    func didTransferImage(cell: ImageCell, image: UIImage?)
}
