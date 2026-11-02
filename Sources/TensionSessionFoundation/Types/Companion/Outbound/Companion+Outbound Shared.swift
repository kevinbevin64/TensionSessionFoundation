//
//  Companion+Outbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import WatchConnectivity

extension Companion {
    
    func send(_ operation: SyncInstruction.Outbound) {
        
        guard let dictionary = dictionary(for: operation) else { return }
        
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
        
        guard let dictionary = dictionary(for: operation) else { return }
        
        WCSession.default.sendMessage(
            dictionary,
            replyHandler: replyHandler
        )
    }
    
    func dictionary(for operation: SyncInstruction.Outbound) -> [String: Any]? {
        
        do {
            return try SyncInstruction(operation).dictionaryForm()
        } catch {
            print("Failed to encode sync instruction: \(error.localizedDescription)")
            return nil
        }
    }
}
