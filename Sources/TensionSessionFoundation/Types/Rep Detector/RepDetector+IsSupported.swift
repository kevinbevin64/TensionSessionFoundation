//
//  RepDetector-IsSupported.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import CoreMotion

public extension RepDetector {
    
    static var isSupported: Bool {
        
        CMMotionManager().isDeviceMotionAvailable
    }
}
