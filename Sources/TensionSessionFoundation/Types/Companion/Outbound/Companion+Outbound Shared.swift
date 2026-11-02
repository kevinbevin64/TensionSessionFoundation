//
//  Companion+Outbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import WatchConnectivity

extension Companion {
    
    func send(_ operation: SyncInstruction.Outbound) {

        let dictionary = try? SyncInstruction(operation).dictionaryForm()

        guard let dictionary else { return }
        
        #if DEBUG
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: nil
        )
        #else
        WCSession.default.transferUserInfo(dictionary)
        #endif
    }
    
    func sendInstantly(
        _ operation: SyncInstruction.Outbound,
        replyHandler: (([String: Any]) -> Void)? = nil
    ) {
        
        let dictionary = try? SyncInstruction(operation).dictionaryForm()

        guard let dictionary else { return }

        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler
        )
    }
}
