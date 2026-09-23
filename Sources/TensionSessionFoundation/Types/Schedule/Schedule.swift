//
//  Schedule.swift
//  TensionSession
//
//  Created by Kevin on 9/22/26.
//

import Foundation

public final class Schedule {
    
    private let action: @MainActor () -> Void
    
    private var scheduledTask: Task<Void, Never>?
    
    public init(action: @escaping @MainActor () -> Void) {
        self.action = action
    }
    
    public func invoke(
        after delay: Duration,
        loopingEvery interval: Duration? = nil
    ) {
        
        scheduledTask?.cancel()
        
        scheduledTask = Task { @MainActor [weak self] in
            
            try? await Task.sleep(for: delay)

            guard let interval else {
                if !Task.isCancelled, let self {
                    self.action()
                }
                return
            }
            
            while !Task.isCancelled {
                guard let self else { return }
                self.action()
                try? await Task.sleep(for: interval)
            }
        }
    }

    public func cancel() {
        scheduledTask?.cancel()
    }
}
