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
        
        print("Received message: \(message)")
        
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
            
            do {
                
                let instruction = try SyncInstruction(fromDictionary: dictionary)
                
                guard let operation = instruction.inbound else {
                    assertionFailure()
                    return
                }
                
                #if os(iOS)
                self?.process(operation, replyHandler: replyHandler)
                #elseif os(watchOS)
                self?.process(operation)
                #endif
                
            } catch {
                
                print("Failed to create instruction")
                
            }
        }
    }
}
