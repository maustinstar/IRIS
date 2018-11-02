//
//  ImageTransferDelegate.swift
//  IRIS
//
//  Created by Michael Verges on 11/1/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import Foundation

public protocol ImageTransferDelegate {
    func transferProgressDidChange(to: CGFloat)
}
