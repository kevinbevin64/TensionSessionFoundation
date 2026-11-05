//
//  HealthKitManager+Inbound.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/5/26.
//

import HealthKit

// MARK: Session

extension HKWorkoutManager: HKWorkoutSessionDelegate {
    
    func receiveStateChange(
        of sessionID: ObjectIdentifier,
        to state: HKWorkoutSessionState,
        at date: Date
    ) {
        
        guard isCurrentSession(sessionID) else { return }
        
        switch state {
        
        case .running:
            self.state = .running
        
        case .paused:
            self.state = .paused
        
        case .stopped:
            finishWorkout(at: date)
        
        case .ended:
            self.state = .ended
            resetSession()
        
        default:
            break
            
        }
    }
    
    func receiveFailure(of sessionID: ObjectIdentifier) {
        
        guard isCurrentSession(sessionID) else { return }
        
        state = .ended
        session?.end()
        resetSession()
    }
    
    // Ignores events from sessions that have already ended.
    func isCurrentSession(_ sessionID: ObjectIdentifier) -> Bool {
        
        guard let session else { return false }
        return ObjectIdentifier(session) == sessionID
    }
    
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
            self?.receiveStateChange(of: sessionID, to: toState, at: date)
        }
    }
    
    nonisolated
    public func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: any Swift.Error
    ) {
        
        print("Workout session failed: \(error.localizedDescription)")
        
        let sessionID = ObjectIdentifier(workoutSession)
        
        DispatchQueue.main.async { [weak self] in
            self?.receiveFailure(of: sessionID)
        }
    }
}

// MARK: Builder

extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    nonisolated
    public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    nonisolated
    public func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {}
}
