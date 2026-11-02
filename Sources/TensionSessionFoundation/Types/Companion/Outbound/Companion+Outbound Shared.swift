//
//  Companion+Outbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import WatchConnectivity

public extension Companion {
    
    func send(_ dictionary: [String: Any]) {
        
        #if DEBUG
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: nil
        )
        #else
        WCSession.default.transferUserInfo(
            dictionary
        )
        #endif
    }
    
    func sendInstantly(
        _ dictionary: [String: Any],
        replyHandler: (([String : Any]) -> Void)? = nil,
        errorHandler: ((any Swift.Error) -> Void)? = nil
    ) {
        
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler,
            errorHandler: errorHandler
        )
    }
}
