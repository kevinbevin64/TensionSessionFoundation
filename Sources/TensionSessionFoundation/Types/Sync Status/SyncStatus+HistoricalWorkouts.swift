//
//  SyncStatus+HistoricalWorkouts.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/4/26.
//

extension SyncStatus {
    
    enum HistoricalWorkouts: Codable, WatchTransferrable {
        
        case matched
        
        case notMatched([Workout.DTO])
    }
}
