//
//  Companion+Inbound Phone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import WatchConnectivity

#if os(iOS)
public extension Companion {
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        process(message, replyHandler: replyHandler)
    }
}

extension Companion {
    
    func process(
        _ operation: SyncInstruction.Inbound,
        replyHandler: (([String: Any]) -> Void)?
    ) {
        
        switch operation {
            
        case .addHistoricalWorkout:
            assertionFailure("Receiving historical workouts isn't supported yet")
            
        case .templateWorkoutsHashCheckRequest(let hash):
            replyHandler?(receiveTemplateWorkoutsHashCheckRequest(hash))
            
        case .exerciseCatalogHashCheckRequest(let hash):
            replyHandler?(receiveExerciseCatalogHashCheckRequest(hash))
            
        }
    }
    
    func receiveTemplateWorkoutsHashCheckRequest(
        _ watchHash: WorkoutManager.TemplateWorkoutsHash
    ) -> [String: Any] {
        
        guard let workoutManager else { return [:] }
        
        let phoneHash = workoutManager.getTemplateWorkoutsHash()
        
        let syncStatus: SyncStatus.TemplateWorkouts
        
        if watchHash == phoneHash {
            syncStatus = .matched
        } else {
            syncStatus = .notMatched(workoutManager.sortedTemplates.map { $0.getDTO() })
        }
        
        return dictionary(for: .templateWorkoutsHashCheckReply(status: syncStatus)) ?? [:]
    }
    
    func receiveExerciseCatalogHashCheckRequest(
        _ watchHash: Exercise.Catalog.DTO.Hash
    ) -> [String: Any] {
        
        guard let catalog = getExerciseCatalogDTO?() else { return [:] }
        
        let syncStatus: SyncStatus.ExerciseCatalog
        
        if watchHash == catalog.getHash() {
            syncStatus = .matched
        } else {
            syncStatus = .notMatched(catalog)
        }
        
        return dictionary(for: .exerciseCatalogHashCheckReply(status: syncStatus)) ?? [:]
    }
}
#endif // os(iOS)
