//
//  Companion+Outbound Watch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

#if os(watchOS)
public extension Companion {
    
    func requestTemplateWorkoutsHashCheck() {
        
        guard let hash = workoutManager?.getTemplateWorkoutsHash() else { return }
        
        sendInstantly(
            .templateWorkoutsHashCheckRequest(hash: hash),
            replyHandler: { reply in self.process(reply) }
        )
    }
    
    func requestExerciseCatalogHashCheck() {
        
        guard let hash = getExerciseCatalogDTO?().getHash() else { return }
        
        sendInstantly(
            .exerciseCatalogHashCheckRequest(hash: hash),
            replyHandler: { reply in self.process(reply) }
        )
    }
}
#endif // os(watchOS)
