//
//  HealthKitManager+Authorization.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

import HealthKit

public extension HKWorkoutManager {
    
    enum Authorization {
        
        case unavailable
        
        case notDetermined
        
        case denied
        
        case allowed
    }
    
    static var workoutAuthorization: Authorization {
        
        guard HKHealthStore.isHealthDataAvailable() else { return .unavailable }
        
        switch HKHealthStore().authorizationStatus(for: HKQuantityType.workoutType()) {
        case .sharingAuthorized: return .allowed
        case .sharingDenied: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    
    static func requestAuthorization() async throws {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            throw Error.healthDataUnavailable
        }
        
        try await HKHealthStore().requestAuthorization(toShare: shareTypes, read: [])
    }
    
    private static let shareTypes: Set = [
        HKQuantityType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.heartRate)
    ]
}
