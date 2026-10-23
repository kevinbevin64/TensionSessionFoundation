//
//  HealthKitManager+BuilderDelegate.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/23/26.
//

import HealthKit

extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    nonisolated public func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    nonisolated public func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {}
}
