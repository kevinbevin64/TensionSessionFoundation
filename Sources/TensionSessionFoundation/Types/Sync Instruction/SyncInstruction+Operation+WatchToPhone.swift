//
//  SyncInstruction+Operation+WatchToPhone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/22/26.
//

extension SyncInstruction.Operation {
    
    enum WatchToPhone: Codable {
        
        case addHistoricalWorkouts(workouts: [Workout.DTO])
        case historicalWorkoutsHashCheckRequest(hash: WorkoutManager.HistoricalWorkoutsHash)
        case templateWorkoutsHashCheckRequest(hash: WorkoutManager.TemplateWorkoutsHash)
        case exerciseCatalogHashCheckRequest(hash: Exercise.Catalog.DTO.Hash)
        case requestTemplateWorkoutEditApproval(former: Workout.DTO, final: Workout.DTO)

        // User Info

        case requestUserInfoEditApproval(former: UserInfo.DTO, final: UserInfo.DTO)
        case requestUserInfoOverwrite
    }
}
