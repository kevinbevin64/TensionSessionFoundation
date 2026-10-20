//
//  RepDetector+MotionSample.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import Foundation

public extension RepDetector {

    nonisolated
    struct MotionSample: Codable, Sendable {
        
        public let timestamp: TimeInterval
        public let x: Double
        public let y: Double
        public let z: Double
    }
}

