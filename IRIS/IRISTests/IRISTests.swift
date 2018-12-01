//
//  IRISTests.swift
//  IRISTests
//
//  Created by Michael Verges on 10/19/18.
//  Copyright © 2018 Michael Verges. All rights reserved.
//

import XCTest
import UIKit
@testable import IRIS

class IRISTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testModel() {
        let model = IRISCNN2()
        
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: model.inputSize.0, height: model.inputSize.1))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        
        measure {
            run(model, on: patch!)
        }
    }
    
    func run(_ model: Model, on patch: Patch) {
        do {
            let prediction = try model.predict(image: patch.buffer)
            _ = Patch(buffer: prediction, position: (0, 0), size: (512, 512)).uiImage
        } catch {
            print("fail")
        }
    }
    
    let metrics = [
        XCTPerformanceMetric.wallClockTime, XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentVMAllocations"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_UserTime")
    ]
}
