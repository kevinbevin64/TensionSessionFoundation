//
//  SyncInstruction+Operation+WatchToPhone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/22/26.
//

extension SyncInstruction.Operation {
    
    enum WatchToPhone: Codable {
        
        case addHistoricalWorkout(workout: Workout.DTO)
        case templateWorkoutsHashCheckRequest(hash: WorkoutManager.TemplateWorkoutsHash)
        case exerciseCatalogHashCheckRequest(hash: Exercise.Catalog.DTO.Hash)
    }
}
