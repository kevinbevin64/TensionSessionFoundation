//
//  SyncInstruction+Operation.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

extension SyncInstruction {
    
    nonisolated
    enum Operation: String, Codable {
        
        // iOS -> watchOS
        
        case addTemplateWorkout
        case editTemplateWorkout
        case deleteTemplateWorkout
        case templateWorkoutsHashCheckReply
        
        // watchOS -> iOS
        
        case addHistoricalWorkout
        case templateWorkoutsHashCheckRequest
        case addCustomExerciseKindRequest
    }
}
