//
//  Companion+Inbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import Foundation
import WatchConnectivity

public extension Companion {
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        process(message)
    }
    
    nonisolated
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        process(userInfo)
    }
}

extension Companion {
    
    nonisolated
    func process(
        _ dictionary: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil
    ) {
        
        nonisolated(unsafe) let dictionary = dictionary
        nonisolated(unsafe) let replyHandler = replyHandler
        
        DispatchQueue.main.async { [weak self] in
            
            let instruction: SyncInstruction
            
            do {
                instruction = try SyncInstruction(fromDictionary: dictionary)
            } catch {
                print("Failed to decode sync instruction: \(error.localizedDescription)")
                return
            }
            
            guard let operation = instruction.inbound else {
                assertionFailure("Received a sync instruction meant for the other device")
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
