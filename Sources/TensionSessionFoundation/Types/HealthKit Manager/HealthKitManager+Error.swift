//
//  HealthKitManager+Error.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

public extension HKWorkoutManager {
    
    enum Error: Swift.Error, Equatable {
        
        case healthDataUnavailable
        
        case notAuthorized
        
        case failedToStart(String)
        
        case sessionFailed(String)
        
        case failedToSave(String)
        
        public var reason: String {
            
            switch self {
            case .healthDataUnavailable:
                return "Health data is not available on this device."
            case .notAuthorized:
                return "Tension Session is not allowed to save workouts to Health."
            case .failedToStart(let description):
                return "The workout could not be started. \(description)"
            case .sessionFailed(let description):
                return "The workout stopped unexpectedly. \(description)"
            case .failedToSave(let description):
                return "The workout could not be saved to Health. \(description)"
            }
        }
    }
}
