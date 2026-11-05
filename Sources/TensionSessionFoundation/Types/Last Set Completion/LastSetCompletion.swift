//
//  LastSetCompletion.swift
//  TensionSession
//
//  Created by Kevin on 10/23/26.
//

import Foundation

public struct LastSetCompletion {
    
    public var exercise: Exercise
    
    public var restStartInstant: Date
    
    public init(
        exercise: Exercise,
        restStartInstant: Date
    ) {
        self.exercise = exercise
        self.restStartInstant = restStartInstant
    }
}
