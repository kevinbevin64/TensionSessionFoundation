//
//  SyncInstruction+Operation+PhoneToWatch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/22/26.
//

import Foundation

extension SyncInstruction.Operation {
    
    enum PhoneToWatch: Codable {
        
        case addTemplateWorkout(workout: Workout.DTO)
        case editTemplateWorkout(workout: Workout.DTO)
        case deleteTemplateWorkout(id2: UUID)
        case templateWorkoutsHashCheckReply(status: SyncStatus.TemplateWorkouts)
        case exerciseCatalogHashCheckReply(status: SyncStatus.ExerciseCatalog)
        case editExerciseCatalog(catalog: Exercise.Catalog.DTO)
    }
}
