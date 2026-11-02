//
//  Companion+Inbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import Foundation
import WatchConnectivity

extension Companion {
    
    nonisolated
    public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        process(message)
    }
    
    nonisolated
    public func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        process(userInfo)
    }
    
    nonisolated
    func process(
        _ dictionary: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil
    ) {
        
        nonisolated(unsafe) let dictionary = dictionary
        nonisolated(unsafe) let replyHandler = replyHandler
        
        DispatchQueue.main.async { [weak self] in

            guard let instruction = try? SyncInstruction(fromDictionary: dictionary),
                  let operation = instruction.inbound else
            {
                return
            }
            
            #if os(iOS)
            self?.process(operation, replyHandler: replyHandler)
            #elseif os(watchOS)
            self?.process(operation)
            #endif
        }
    }
}
