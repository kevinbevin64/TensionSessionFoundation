//
//  HealthKitManager+BuilderDelegate.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

import HealthKit

extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    nonisolated
    public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
        let eventName = workoutBuilder.workoutEvents.last.map { HKWorkoutManager.describe($0.type) } ?? "unknown"
        
        DispatchQueue.main.async { [weak self] in
            self?.log("Builder event: \(eventName)")
        }
    }
    
    nonisolated
    public func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        
        let typeNames = collectedTypes.map { HKWorkoutManager.displayName(of: $0.identifier) }
        
        DispatchQueue.main.async { [weak self] in
            self?.builderDidCollect(typeNames)
        }
    }
}
