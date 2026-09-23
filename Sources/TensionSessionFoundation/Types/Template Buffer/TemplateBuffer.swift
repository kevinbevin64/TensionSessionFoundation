//
//  TemplateBuffer.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import Foundation

@Observable
final public class TemplateBuffer {
    
    public private(set) var selection: Workout?
    
    private var healthKitManager: HKWorkoutManager
    
    var onInsertion: (UUID) -> Void
    
    var onEmptying: () -> Void
    
    public init(
        onInsertion: @escaping (UUID) -> Void,
        onEmptying: @escaping () -> Void
    ) {
        self.healthKitManager = HKWorkoutManager()
        self.onInsertion = onInsertion
        self.onEmptying = onEmptying
    }
}

@MainActor
public extension TemplateBuffer {
    
    var canSelectionBeBlindlyOverwritten: Bool {
        guard let selection else { return true }
        return selection.state == .unstarted
    }
    
    var isReadyToEvictFinishedWorkout: Bool {
        guard let selection else { return false }
        return selection.state == .ended && selection.startInstant != nil
    }
    
    func insert(_ template: Workout) {
        
        print("This template has \(template.sortedExercises.count) exercises")
        
        assert(template.state == .unstarted)
        assert(template.startInstant == nil)
        if let selection {
            assert(selection.state == .unstarted || selection.state == .ended)
        }
        
        selection = template
        onInsertion(template.id2)
    }
    
    func clearSelection() {
        
        if let selection {
            assert(
                selection.state == .unstarted
                || selection.state == .ended
            )
        }
        
        selection = nil
        onEmptying()
    }
    
    func start() {
        
        guard let selection else {
            assertionFailure()
            return
        }
        
        let copy = Workout(
            id2: selection.id2,
            order: 0,
            name: selection.name,
            state: selection.state,
            startInstant: selection.startInstant,
            exercises: selection.sortedExercises.duplicated()
        )
        self.selection = copy
        
        guard let selection = self.selection else {
            assertionFailure()
            return
        }
        
        selection.start()
        
        healthKitManager.start()
    }
    
    func pause() {
        
        guard let selection else {
            assertionFailure()
            return
        }
        
        selection.pause()
        
        healthKitManager.pause()
    }
    
    func resume() {
        
        guard let selection else {
            assertionFailure()
            return
        }
        
        selection.resume()
        
        healthKitManager.resume()
    }
    
    func end() {
        
        guard let selection else {
            assertionFailure()
            return
        }
        
        selection.end()
        
        healthKitManager.end()
    }
}
