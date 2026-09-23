//
//  Workout+Lifecycle.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import Foundation

@MainActor
public extension Workout {
    
    @discardableResult
    func addExercise(
        kind: Exercise.Catalog.Kind,
        equipment: Exercise.Equipment,
        setsPlanned: Int,
        repsPlanned: Int,
        weightPlanned: Weight,
        catalog: Exercise.Catalog
    ) throws -> Exercise {
        
        guard catalog.contains(kind.name) else {
            throw Error.kindDoesNotExist
        }
        
        let utilizedKinds = sortedExercises.map { $0.kind }
        guard !utilizedKinds.contains(where: {
            $0.name == kind.name
        }) else {
            throw Error.kindAlreadyUtilized
        }
        
        let exercise = Exercise(
            order: unsortedExercises.count,
            kind: kind,
            equipment: equipment,
            setsPlanned: setsPlanned,
            repsPlanned: repsPlanned,
            weightPlanned: weightPlanned
        )
        
        unsortedExercises.append(exercise)
//        sortedExercises = unsortedExercises.sorted { $0.order < $1.order }
        
        return exercise
    }
    
    func deleteExercise(withId2 id2: UUID) {
        
        assert(unsortedExercises.contains(where: { $0.id2 == id2 }))
        
        unsortedExercises.removeAll(where: { $0.id2 == id2 })
//        sortedExercises = unsortedExercises.sorted { $0.order < $1.order }
        setOrder()
    }
    
    func isOrderValid() -> Bool {
        
        for (i, exercise) in sortedExercises.enumerated() {
            if exercise.order != i {
                return false
            }
        }
        return true
    }
    
    func setOrder() {
        
        for (i, exercise) in sortedExercises.enumerated() {
            exercise.order = i
        }
    }
}
