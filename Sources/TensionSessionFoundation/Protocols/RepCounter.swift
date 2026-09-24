//
//  RepCounter.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

public protocol RepCounter {
    
    static func getRepCount(in: [RepDetector.MotionSample]) -> Int
}
