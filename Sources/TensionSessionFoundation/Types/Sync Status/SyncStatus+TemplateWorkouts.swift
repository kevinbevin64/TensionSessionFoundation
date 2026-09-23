//
//  SyncStatus+TemplateWorkouts.swift
//  TensionSession
//
//  Created by Kevin on 9/16/26.
//

extension SyncStatus {
    
    enum TemplateWorkouts: Codable, WatchTransferrable {
        
        case matched
        
        case notMatched([Workout.DTO])
    }
}
