//
//  Companion+Outbound Watch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

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
#endif // os(watchOS)
