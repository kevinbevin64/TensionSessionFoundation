//
//  Companion+Outbound Watch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

#if os(watchOS)
public extension Companion {
    
    func requestTemplateWorkoutsHashCheck() {
        
        guard let hash = workoutManager?.getTemplateWorkoutsHash() else {
            assertionFailure()
            return
        }

        sendInstantly(
            .templateWorkoutsHashCheckRequest(hash: hash),
            replyHandler: { self.process($0) }
        )
    }
    
    func requestExerciseCatalogHashCheck() {
        
        guard let hash = getExerciseCatalogDTO?().getHash() else {
            assertionFailure()
            return
        }

        sendInstantly(
            .exerciseCatalogHashCheckRequest(hash: hash),
            replyHandler: { self.process($0) }
        )
    }
}
#endif // os(watchOS)
