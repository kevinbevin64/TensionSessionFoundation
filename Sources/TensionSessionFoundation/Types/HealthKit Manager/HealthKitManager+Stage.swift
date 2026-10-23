//
//  HealthKitManager+Stage.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

public extension HKWorkoutManager {
    
    enum Stage: Equatable {
        
        case idle
        
        case starting
        
        case running
        
        case paused
        
        case stopping
        
        case errored(Error)
    }
}
