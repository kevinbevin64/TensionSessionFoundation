//
//  Companion+Inbound.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import Foundation
import WatchConnectivity

// MARK: Both iOS and watchOS

public extension Companion {
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        
        print("Received message: \(message)")
        
        process(message)
    }
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        process(userInfo)
    }
}

extension Companion {
    
    nonisolated
    func process(
        _ dictionary: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil
    ) {

        nonisolated(unsafe) let dictionary = dictionary
        nonisolated(unsafe) let replyHandler = replyHandler
        
        DispatchQueue.main.async { [weak self] in
            
            do {
                
                let instruction = try SyncInstruction(fromDictionary: dictionary)
                
                guard let operation = instruction.inbound else {
                    assertionFailure()
                    return
                }
                
                #if os(iOS)
                self?.process(operation, replyHandler: replyHandler)
                #elseif os(watchOS)
                self?.process(operation)
                #endif
                
            } catch {
                
                print("Failed to create instruction")
                
            }
        }
    }
}

// MARK: watchOS

#if os(watchOS)
extension Companion {
    
    func receiveNewTemplate(_ workout: Workout.DTO) {
        
        workoutManager?.addWorkout(Workout(fromDTO: workout))
    }
    
    func receiveEditedTemplate(_ workout: Workout.DTO) {
        
        workoutManager?.editTemplate(accordingTo: Workout(fromDTO: workout))
    }
    
    func receiveTemplateToBeDeleted(_ id2: UUID) {
        
        guard let workout = workoutManager?.unsortedTemplates.first(where: { $0.id2 == id2 }) else {
            return
        }
        
        workoutManager?.deleteTemplate(workout)
    }
    
    func receiveTemplateWorkoutsHashCheckReply(_ syncStatus: SyncStatus.TemplateWorkouts) {
        
        print("RECEIVED REPLY!!!")
        
        switch syncStatus {
            
        case .matched:
            print("Matched")
            
        case .notMatched(let workouts):
            print("Did not match")
            workoutManager?.overwriteTemplates(workouts.map { Workout(fromDTO: $0) })
            
        }
    }
    
    func receiveExerciseCatalogHashCheckReply(_ syncStatus: SyncStatus.ExerciseCatalog) {
        
        print("RECEIVED REPLY!!!")
        
        switch syncStatus {
            
        case .matched:
            print("Matched")
            
        case .notMatched(let catalogDTO):
            print("Did not match")
            editCatalog?(catalogDTO)
            
        }
    }
    
    func receiveEditedCatalogDTO(_ catalogDTO: Exercise.Catalog.DTO) {
        
        editCatalog?(catalogDTO)
    }
    
    func process(_ operation: SyncInstruction.Inbound) {
        
        switch operation {
        
        case .addTemplateWorkout(let workout):
            receiveNewTemplate(workout)
            
        case .editTemplateWorkout(let workout):
            receiveEditedTemplate(workout)
            
        case .deleteTemplateWorkout(let id2):
            receiveTemplateToBeDeleted(id2)
            
        case .templateWorkoutsHashCheckReply(let status):
            receiveTemplateWorkoutsHashCheckReply(status)
            
        case .exerciseCatalogHashCheckReply(let status):
            receiveExerciseCatalogHashCheckReply(status)
            
        case .editExerciseCatalog(let catalog):
            receiveEditedCatalogDTO(catalog)
            
        }
    }
}
#endif // os(watchOS)

// MARK: iOS

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
