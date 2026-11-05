//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

///
/// Follows Apple's sample code
/// - Building a workout app for iPhone and iPad (WWDC25)
/// - Build a workout app for Apple Watch (WWDC21)
///
/// Only one workout session can run at a time.
///

import HealthKit
import Observation

@Observable
@MainActor
public final class HKWorkoutManager: NSObject {
    
    public private(set) var state: HKWorkoutSessionState = .notStarted
    
    // MARK: Variables
    
    let healthStore = HKHealthStore()
    
    var session: HKWorkoutSession?
    
    var builder: HKLiveWorkoutBuilder?
    
    static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    public override init() {
        
        super.init()
    }
}
