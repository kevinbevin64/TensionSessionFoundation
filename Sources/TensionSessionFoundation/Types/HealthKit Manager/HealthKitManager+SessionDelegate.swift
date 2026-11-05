//
//  HealthKitManager+SessionDelegate.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

import HealthKit

extension HKWorkoutManager: HKWorkoutSessionDelegate {
    
    nonisolated
    public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        
        let sessionID = ObjectIdentifier(workoutSession)
        
        // The main queue runs these in order, so state changes are handled in the order they happen.
        DispatchQueue.main.async { [weak self] in
            self?.sessionDidChange(sessionID, from: fromState, to: toState, at: date)
        }
    }
    
    nonisolated
    public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: any Swift.Error
    ) {
        
        let sessionID = ObjectIdentifier(workoutSession)
        
        let description = error.localizedDescription
        
        DispatchQueue.main.async { [weak self] in
            self?.sessionDidFail(sessionID, description: description)
        }
    }
}
