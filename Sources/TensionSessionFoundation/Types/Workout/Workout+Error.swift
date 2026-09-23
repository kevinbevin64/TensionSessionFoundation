//
//  Workout+Error.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

public extension Workout {
    
    enum Error: Swift.Error {
        
        case kindDoesNotExist
        
        case kindAlreadyUtilized
    }
}
