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

    nonisolated
    func send(dictionary: [String: Any]) {

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
        replyHandler: (([String: Any]) -> Void)? = nil,
        sendSlowlyOnError: Bool = false,
    ) {
        
        let dictionary = try? SyncInstruction(operation).dictionaryForm()

        guard let dictionary else { return }

        var errorHandler: ((any Error) -> Void)? = nil
        if sendSlowlyOnError {
            errorHandler = { _ in
                self.send(dictionary: dictionary)
            }
        }

        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler,
            errorHandler: errorHandler
        )
    }
}
