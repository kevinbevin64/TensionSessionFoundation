//
//  Companion+State.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/4/26.
//

import WatchConnectivity

#if os(iOS)
extension Companion {
    
    nonisolated func updateStateProperties(_ session: WCSession) {
        
        if session.activationState == .activated {
            
            let isReachable = session.isReachable
            let isPaired = session.isPaired
            let isWatchAppInstalled = session.isWatchAppInstalled
            
            DispatchQueue.main.async {
                self.isReachable = isReachable
                self.isPaired = isPaired
                self.isWatchAppInstalled = isWatchAppInstalled
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.isReachable = nil
                self.isPaired = nil
                self.isWatchAppInstalled = nil
            }
            
        }
    }
}

public extension Companion {
    
    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        
        updateStateProperties(session)
    }
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        
        if session.activationState == .activated {
            
            let isReachable = session.isReachable
            
            DispatchQueue.main.async { [weak self] in
                if self?.isReachable == false && isReachable == true {
                    self?.requestHistoricalWorkoutsHashCheck()
                }
            }
        }
        
        updateStateProperties(session)
    }
}
#endif // os(iOS)

#if os(watchOS)
extension Companion {
    
    nonisolated func updateStateProperties(_ session: WCSession) {
        
        if session.activationState == .activated {
            
            let isReachable = session.isReachable
            
            DispatchQueue.main.async {
                self.isReachable = isReachable
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.isReachable = nil
            }
            
        }
    }
}

public extension Companion {
    
    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        
        if session.activationState == .activated {
            
            let isReachable = session.isReachable
            
            DispatchQueue.main.async { [weak self] in
                if self?.isReachable == false && isReachable == true {
                    self?.requestTemplateWorkoutsHashCheck()
                    self?.requestExerciseCatalogHashCheck()
                    self?.requestHistoricalWorkoutsHashCheck()
                }
            }
        }
        
        updateStateProperties(session)
    }
}
#endif // os(watchOS)
