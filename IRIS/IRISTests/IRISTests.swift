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

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    let metrics = [
        XCTPerformanceMetric.wallClockTime, XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentVMAllocations"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_UserTime")
    ]

    func testIRISPerformance() {
        // This is an example of a performance test case.
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        var prediction: UIImage? = UIImage()
        measureMetrics(metrics, automaticallyStartMeasuring: true) {
            prediction = source.enhance()
        }
        print(prediction)
    }
}
