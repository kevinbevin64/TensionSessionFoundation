//
//  Companion+Outbound Phone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

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
