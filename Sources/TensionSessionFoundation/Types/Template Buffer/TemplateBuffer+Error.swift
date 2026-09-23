//
//  TemplateBuffer+Error.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

public extension TemplateBuffer {
    
    enum Error: Swift.Error {
        
        case noSelectedWorkout
        case protectedWorkout
    }
}
