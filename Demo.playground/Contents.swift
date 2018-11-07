//: A UIKit based Playground for presenting user interface

import UIKit
import IRIS

let source = UIImage(named: "Sample.HEIC")!

let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 256, height: 256))
let patch = source.cgImage!.patch(in: rect)

attemptPrediction(patch: patch!)
