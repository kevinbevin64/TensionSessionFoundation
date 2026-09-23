//
//  Exercise+Catalog+CustomAdditionResult.swift
//  TensionSession
//
//  Created by Kevin on 9/17/26.
//

public extension Exercise.Catalog {
    
    enum CustomAdditionResult {
        
        case added
        
        case needsConfirmation(Confirmation)
        
        public final class Confirmation {
            
            let similarNames: [String]
            
            private var hasConfirmedAddition: Bool
            
            private var confirmAddition: (Bool) -> Void
            
            init(similarNames: [String], confirmAddition: @escaping (Bool) -> Void) {
                self.similarNames = similarNames
                self.hasConfirmedAddition = false
                self.confirmAddition = confirmAddition
            }
            
            public func confirm(shouldProceed: Bool) {
                
                guard hasConfirmedAddition == false else { return }
                
                hasConfirmedAddition = true
                
                confirmAddition(shouldProceed)
            }
        }
    }
}
