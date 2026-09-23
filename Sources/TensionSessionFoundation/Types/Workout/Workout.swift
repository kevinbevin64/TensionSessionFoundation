//
//  Workout.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import Foundation
import SwiftData

@Model
public final class Workout {
    
    public var id2: UUID
    
    public var order: Int
    
    public var name: String
    
    public var state: State
    
    public var startInstant: Date?
    
    public var sortedExercises: [Exercise] {
        unsortedExercises.sorted {
            $0.order < $1.order
        }
    }
    
    @Relationship(deleteRule: .cascade)
    public internal(set) var unsortedExercises: [Exercise]
    
    public init(
        id2: UUID,
        order: Int,
        name: String,
        state: State,
        startInstant: Date?,
        exercises: [Exercise]
    ) {
        self.id2 = id2
        self.order = order
        self.name = name
        self.state = state
        self.startInstant = startInstant
        self.unsortedExercises = exercises
    }
    
    public init(
        order: Int,
        name: String,
    ) {
        self.id2 = UUID()
        self.order = order
        self.name = name
        self.state = .unstarted
        self.startInstant = nil
        self.unsortedExercises = []
    }
}
