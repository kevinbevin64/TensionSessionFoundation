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
        
        print("Received message with reply handler")
        
        process(message, replyHandler: replyHandler)
    }
}

extension Companion {
    
    func receiveTemplateWorkoutsHashCheckRequest(
        _ watchHash: WorkoutManager.TemplateWorkoutsHash
    ) -> [String: Any] {
        
        print("Received check request!")
        
        do {
            
            guard let phoneHash = workoutManager?.getTemplateWorkoutsHash() else { return [:] } // FIXME:
            
            let syncStatus: SyncStatus.TemplateWorkouts
            
            if watchHash == phoneHash {
                syncStatus = .matched
            } else {
                let templateDTOs = workoutManager?.sortedTemplates.map { $0.getDTO() }
                syncStatus = .notMatched(templateDTOs ?? [])
            }
            
            let instruction = SyncInstruction(
                .templateWorkoutsHashCheckReply(status: syncStatus)
            )
            
            return try instruction.dictionaryForm()
            
        } catch {
            
            print("Failed to create instruction dictionary")
            return [:]
        }
    }
    
    func receiveExerciseCatalogHashCheckRequest(
        _ watchHash: Exercise.Catalog.DTO.Hash
    ) -> [String: Any] {
        
        print("Received check request!")
        
        do {
            
            guard let catalogDTO = getExerciseCatalogDTO?() else { return [:] }
            
            let syncStatus: SyncStatus.ExerciseCatalog
            
            if watchHash == catalogDTO.getHash() {
                syncStatus = .matched
            } else {
                syncStatus = .notMatched(catalogDTO)
            }
            
            let instruction = SyncInstruction(
                .exerciseCatalogHashCheckReply(status: syncStatus)
            )
            
            return try instruction.dictionaryForm()
            
        } catch {
            
            print("Failed to create instruction dictionary")
            return [:]
        }
    }
    
    func process(
        _ operation: SyncInstruction.Inbound,
        replyHandler: (([String: Any]) -> Void)?
    ) {
        
        switch operation {
            
        case .addHistoricalWorkout:
            assertionFailure()
            
        case .templateWorkoutsHashCheckRequest(let hash):
            replyHandler?(receiveTemplateWorkoutsHashCheckRequest(hash))
            
        case .exerciseCatalogHashCheckRequest(let hash):
            replyHandler?(receiveExerciseCatalogHashCheckRequest(hash))
            
        }
    }
}
#endif // os(iOS)
