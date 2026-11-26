//
//  HealthKitManager+WorkoutSavedOnFailure.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/21/26.
//

import HealthKit

extension HealthKitManager {
    
    enum WorkoutSavedOnFailure {
        
        case saving
        
        case savingThenDelete
        
        case saved(HKWorkout)
    }
}
