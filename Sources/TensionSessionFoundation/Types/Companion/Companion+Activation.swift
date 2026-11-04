//
//  Companion+Activation.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

public extension Companion {
    
    func activate() {
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        
        switch activationState {
        
        case .activated:
            print("Activation completed, ending with activated state.")
            DispatchQueue.main.async { [weak self] in
                self?.scheduleHashChecks()
            }
            
        case .inactive:
            print("Activation completed, ending with inactive state.")
            
        case .notActivated:
            print("Activation completed, ending with notActivated state.")
        
        @unknown default:
            print("Unknown case")
        }
        
        if let error {
            print("Activation error: \(error.localizedDescription)")
        }
        
        updateStateProperties(session)
    }
}

#if os(iOS)
public extension Companion {
    
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        
        updateStateProperties(session)
    }
    
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        
        updateStateProperties(session)
    }
}
#endif // os(iOS)

#if os(iOS)
extension Companion {
    
    func scheduleHashChecks() {
        
        let historySchedule = Schedule { [weak self] in
            self?.requestHistoricalWorkoutsHashCheck()
        }
        historySchedule.invoke(after: .seconds(3))
        requestHistoricalWorkoutsHashCheckSchedule = historySchedule
    }
}
#elseif os(watchOS)
extension Companion {
    
    func scheduleHashChecks() {
        
        let templateSchedule = Schedule { [weak self] in
            self?.requestTemplateWorkoutsHashCheck()
        }
        templateSchedule.invoke(after: .seconds(3))
        requestTemplateWorkoutsHashCheckSchedule = templateSchedule
        
        let catalogSchedule = Schedule { [weak self] in
            self?.requestExerciseCatalogHashCheck()
        }
        catalogSchedule.invoke(after: .seconds(3))
        requestExerciseCatalogHashCheckSchedule = catalogSchedule
        
        let historySchedule = Schedule { [weak self] in
            self?.requestHistoricalWorkoutsHashCheck()
        }
        historySchedule.invoke(after: .seconds(3))
        requestHistoricalWorkoutsHashCheckSchedule = historySchedule
    }
}
#endif // os(watchOS)
