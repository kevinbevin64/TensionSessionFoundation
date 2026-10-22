//
//  Companion+Outbound.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

public extension Companion {
    
    func send(_ dictionary: [String: Any]) {
        
        #if DEBUG
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: nil
        )
        #else
        WCSession.default.transferUserInfo(
            dictionary
        )
        #endif
    }
    
    func sendInstantly(
        _ dictionary: [String: Any],
        replyHandler: (([String : Any]) -> Void)? = nil,
        errorHandler: ((any Swift.Error) -> Void)? = nil
    ) {
        
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler,
            errorHandler: errorHandler
        )
    }
}

#if os(iOS)
public extension Companion {
    
    func addTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .addTemplateWorkout(workout: workout.getDTO())
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func editTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .editTemplateWorkout(workout: workout.getDTO())
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func deleteTemplateWorkout(_ workout: Workout) {
        
        do {
            
            let instruction = SyncInstruction(
                .deleteTemplateWorkout(id2: workout.id2)
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func editExerciseCatalog(_ catalog: Exercise.Catalog) {
        
        do {
            
            let instruction = SyncInstruction(
                .editExerciseCatalog(catalog: catalog.getDTO())
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            send(rawInstruction)
            
        } catch {
            
            print("ERROR")
            
        }
    }
}
#endif // os(iOS)

#if os(watchOS)
public extension Companion {
    
    func requestTemplateWorkoutsHashCheck() {
        
        print("Requesting template workouts hash check.")
        
        do {
            
            guard let hash = workoutManager?.getTemplateWorkoutsHash() else {
                return
            }
            
            let instruction = SyncInstruction(
                .templateWorkoutsHashCheckRequest(hash: hash)
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            sendInstantly(
                rawInstruction,
                replyHandler: { dictionary in
                    print("WATCH RECEIVED REPLY DICTIONARY!!!")
                    self.process(dictionary)
                }
            )
            
        } catch {
            
            print("ERROR")
            
        }
    }
    
    func requestExerciseCatalogHashCheck() {
        
        print("Requesting exercise catalog hash check.")
        
        do {
            
            guard let hash = getExerciseCatalogDTO?().getHash() else {
                return
            }
            
            let instruction = SyncInstruction(
                .exerciseCatalogHashCheckRequest(hash: hash)
            )
            let rawInstruction = try instruction.dictionaryForm()
            
            sendInstantly(
                rawInstruction,
                replyHandler: { dictionary in
                    print("WATCH RECEIVED REPLY DICTIONARY!!!")
                    self.process(dictionary)
                }
            )
            
        } catch {
            
            print("ERROR")
            
        }
    }
}
#endif
