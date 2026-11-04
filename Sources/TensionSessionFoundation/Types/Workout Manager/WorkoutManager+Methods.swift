//
//  WorkoutManager+Methods.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import CryptoKit
import Foundation

@MainActor
public extension WorkoutManager {
    
    @discardableResult
    func createNewTemplate(called name: String) -> Workout {
        
        let newTemplate = Workout(
            order: unsortedTemplates.count,
            name: name
        )

        unsortedTemplates.append(newTemplate)

        if templateBuffer.selection == nil {
            templateBuffer.insert(newTemplate)
        }
        
        do {
            try save()
        } catch {
            print("Error: \(error)")
        }
        
        return newTemplate
    }
    
    @discardableResult
    func useBlankTemplate() -> Workout {
        
        let blankTemplate = Workout(order: 0, name: "Blank Workout")
        templateBuffer.insert(blankTemplate)
        return blankTemplate
    }
    
    func deleteTemplate(withId2 id2: UUID) {

        if let selection = templateBuffer.selection,
           selection.id2 == id2 && selection.state == .unstarted
        {
            templateBuffer.clearSelection()
        }

        unsortedTemplates.removeAll { $0.id2 == id2 }
        setTemplateOrder()
    }
    
    func rememberHistoricalWorkout() {
        
        guard let workout = templateBuffer.selection else { return }
        assert(templateBuffer.isReadyToEvictFinishedWorkout)
        
        workout.id2 = UUID()
        
        unsortedHistory.append(workout)
        
        if let freshTemplate = freshTemplate() {
            templateBuffer.insert(freshTemplate)
        } else {
            templateBuffer.clearSelection()
        }
        
        try? save()
        
        companion?.addHistoricalWorkout(workout)
    }
    
    func freshTemplate() -> Workout? {
        
        guard let lastUsedId2 else {
            if let first = sortedTemplates.first {
                print(first.id2)
                assert(first.state == .unstarted)
            }
            return sortedTemplates.first
        }
        
        guard let workoutIndex = unsortedTemplates.firstIndex(
            where: { $0.id2 == lastUsedId2 }
        ) else {
            if let first = sortedTemplates.first {
                assert(first.state == .unstarted)
            }
            return sortedTemplates.first
        }
        
        return unsortedTemplates[workoutIndex]
    }
    
    func isTemplateOrderValid() -> Bool {
        
        for (i, template) in sortedTemplates.enumerated() {
            if template.order != i {
                return false
            }
        }
        return true
    }
    
    func setTemplateOrder() {
        
        for (i, template) in sortedTemplates.enumerated() {
            template.order = i
        }
    }
    
    func getTemplateWorkoutsHash() -> TemplateWorkoutsHash {
        
        let dtos = sortedTemplates.map { $0.getDTO() }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try? encoder.encode(dtos)
        let digest = Data(SHA256.hash(data: data ?? Data()))
        let hash = TemplateWorkoutsHash(digest: digest)
        
        return hash
    }
    
    func getHistoricalWorkoutsHash() -> HistoricalWorkoutsHash {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let workoutDigests = unsortedHistory
            .map { workout in
                let data = try? encoder.encode(workout.getDTO())
                return Data(SHA256.hash(data: data ?? Data()))
            }
            .sorted { $0.lexicographicallyPrecedes($1) }
        let digest = Data(SHA256.hash(data: workoutDigests.reduce(Data(), +)))
        
        return HistoricalWorkoutsHash(digest: digest)
    }
    
    func add(_ workout: Workout) {
        
        workout.order = unsortedTemplates.count

        unsortedTemplates.append(workout)

        if templateBuffer.selection == nil {
            templateBuffer.insert(workout)
        }
        
        try? save()
    }
}

// MARK: Invoked by Companion

@MainActor
extension WorkoutManager {
    
    func addWorkout(_ workout: Workout) {
        
        workout.order = unsortedTemplates.count

        unsortedTemplates.append(workout)

        if templateBuffer.selection == nil {
            templateBuffer.insert(workout)
        }
        
        try? save()
    }
    
    func editTemplate(accordingTo workout: Workout) {
        
        guard let index = unsortedTemplates.firstIndex(where: {
            $0.id2 == workout.id2
        }) else {
            return
        }
        
        let actualWorkout: Workout = unsortedTemplates[index]
        
        actualWorkout.name = workout.name
        assert(workout.state == .unstarted)
        assert(workout.startInstant == nil)
        actualWorkout.unsortedExercises = workout.unsortedExercises
        
        try? save()
    }
    
    func deleteTemplate(_ workout: Workout) {
        
        let id2 = workout.id2
        
        unsortedTemplates.removeAll { $0.id2 == id2 }
        setTemplateOrder()

        if let selection = templateBuffer.selection,
           selection.id2 == id2 && selection.state == .unstarted
        {
            if let freshTemplate = freshTemplate() {
                templateBuffer.insert(freshTemplate)
            } else {
                templateBuffer.clearSelection()
            }
        }
        
        try? save()
    }
    
    func addHistoricalWorkout(_ workout: Workout) {
        
        guard workout.state == .ended, workout.startInstant != nil else {
            assertionFailure("Received an unfinished historical workout")
            return
        }
        
        let dto = workout.getDTO()
        guard unsortedHistory.contains(where: { $0.getDTO() == dto }) == false else {
            return
        }
        
        unsortedHistory.append(workout)
        try? save()
    }
    
    func makeHistoricalWorkoutId2sUnique() {
        
        var seenId2s = Set<UUID>()
        var didChange = false
        
        for workout in sortedHistory.reversed() {
            if seenId2s.insert(workout.id2).inserted == false {
                workout.id2 = UUID()
                seenId2s.insert(workout.id2)
                didChange = true
            }
        }
        
        if didChange {
            try? save()
        }
    }
    
    func overwriteTemplates(_ templates: [Workout]) {
        
        print("Overwriting templates with \(templates.count) templates")
        
        
        if let selection = templateBuffer.selection,
           selection.state == .unstarted
        {
            templateBuffer.clearSelection()
        }
        
        unsortedTemplates.removeAll()
        unsortedTemplates.append(contentsOf: templates)
        
        if let freshTemplate = freshTemplate() {
            
            if let selection = templateBuffer.selection {
                
                if selection.state == .unstarted {
                    
                    templateBuffer.insert(freshTemplate)
                }
            } else {
                
                templateBuffer.insert(freshTemplate)
            }
        }
        
        try? save()
    }
}
