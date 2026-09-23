//
//  Workout+Methods.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import Foundation

@MainActor
public extension Workout {
    
    func start() {
        assert(state == .unstarted)
        self.state = .resumed
    }
    
    func pause() {
        assert(state == .resumed)
        self.state = .paused
    }
    
    func resume() {
        assert(state == .paused)
        self.state = .resumed
    }
    
    func end() {
        assert(state == .resumed || state == .paused)
        self.state = .ended
        self.startInstant = Date.now
    }
}
