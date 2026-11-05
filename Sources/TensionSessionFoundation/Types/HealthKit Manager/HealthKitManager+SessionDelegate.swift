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
        Task { @MainActor in
            switch toState {
            case .running:
                self.state = .running
            case .paused:
                self.state = .paused
            default:
                break
            }
        }

        // Yield the state change synchronously so changes are handled in the order they happen.
        stateChanges.continuation.yield(SessionStateChange(newState: toState, date: date))
    }

    nonisolated public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Swift.Error
    ) {
        print("Workout session failed: \(error)")
    }
}
