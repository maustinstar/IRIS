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
    
    func testPredictionIRISCNN() {
        
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect2 = CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 200))
        let patch2 = source.cgImage!.patch(in: rect2, at: (0 ,0))
        let model2 = IRISCNN2()
        
        measure {
            do {
                let prediction = try model2.prediction(image: patch2!.buffer).output1
                _ = Patch(buffer: prediction, position: (0, 0), size: (200, 200)).uiImage?.scaled()
            } catch {
                print("fail")
            }
        }
        
    }

    func testPredictionDeconv() {
        
        // Create Patch
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 256, height: 256))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        let model = TestConvT_1_1()
        
        // Attempt Prediction
        
        measure {
            do {
                let prediction = try model.prediction(image: patch!.buffer).output1
                _ = Patch(buffer: prediction, position: (0, 0), size: (512, 512)).uiImage
            } catch {
                print("fail")
            }
        }
    }
    
    func testPredictionLighter() {
        
        // Create Patch
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 256, height: 256))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        let model = lighterSRCNN16v2()
        // Attempt Prediction
        
        measure {
            do {
                let prediction = try model.prediction(image: patch!.buffer).output1
                _ = Patch(buffer: prediction, position: (0, 0), size: (512, 512)).uiImage
            } catch {
                print("fail")
            }
        }
    }
    
    func testPredictionFlupSequel() {
        
        // Create Patch
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 512, height: 512))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        let model = lightAsFlupTheSequel()
        // Attempt Prediction
        
        measure {
            do {
                let prediction = try model.prediction(image: patch!.buffer).output1
                _ = Patch(buffer: prediction, position: (0, 0), size: (512, 512)).uiImage
            } catch {
                print("fail")
            }
        }
    }
    
    func testPredictionFlup() {
        
        // Create Patch
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 256, height: 256))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        let model = lightAsFlup()
        // Attempt Prediction
        
        measure {
            do {
                let prediction = try model.prediction(image: patch!.buffer).output1
                _ = Patch(buffer: prediction, position: (0, 0), size: (512, 512)).uiImage
            } catch {
                print("fail")
            }
        }
    }
    
    func testPredictionStarry() {
        
        // Create Patch
        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 720, height: 720))
        let patch = source.cgImage!.patch(in: rect, at: (0 ,0))
        let model = StarryNight()
        // Attempt Prediction
        
        measure {
            do {
                let prediction = try model.prediction(inputImage: patch!.buffer)
                _ = Patch(buffer: prediction.outputImage, position: (0, 0), size: (512, 512)).uiImage
            } catch {
                print("fail")
            }
        }
    }
    
    let metrics = [
        XCTPerformanceMetric.wallClockTime, XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_PersistentVMAllocations"),
        XCTPerformanceMetric(rawValue: "com.apple.XCTPerformanceMetric_UserTime")
    ]

//    func testIRISPerformance() {
//        // This is an example of a performance test case.
//        let source = UIImage(named: "Sample.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
//        measureMetrics(metrics, automaticallyStartMeasuring: true) {
//            _ = source.enhance()
//        }
//    }
}
