//
//  Workout+State.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

public extension Workout {
    
    enum State: Codable {
        
        case unstarted
        case resumed
        case paused
        case ended
    }
}
