//
//  HealthKitManager+SessionDelegate.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

import HealthKit

extension HKWorkoutManager: HKWorkoutSessionDelegate {
    
    nonisolated public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        let sessionID = ObjectIdentifier(workoutSession)
        Task { @MainActor in
            sessionDidChange(sessionID, to: toState, at: date)
        }
    }
    
    nonisolated public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Swift.Error
    ) {
        let sessionID = ObjectIdentifier(workoutSession)
        let description = error.localizedDescription
        Task { @MainActor in
            sessionDidFail(sessionID, withDescription: description)
        }
    }
}
