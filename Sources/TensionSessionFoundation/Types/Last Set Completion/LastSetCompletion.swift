//
//  LastSetCompletion.swift
//  TensionSession
//
//  Created by Kevin on 10/23/26.
//

import Foundation

public struct LastSetCompletion {
    
    public var exercise: Exercise
    
    public var lastSetCompletionInstant: Date
    
    public init(exercise: Exercise, lastSetCompletionInstant: Date) {
        
        self.exercise = exercise
        self.lastSetCompletionInstant = lastSetCompletionInstant
    }
}
