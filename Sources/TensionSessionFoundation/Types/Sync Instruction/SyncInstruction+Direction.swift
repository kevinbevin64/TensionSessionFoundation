//
//  SyncInstruction+Direction.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/22/26.
//

extension SyncInstruction {
    
    #if os(iOS)
    typealias Outbound = Operation.PhoneToWatch
    
    typealias Inbound = Operation.WatchToPhone
    #elseif os(watchOS)
    typealias Outbound = Operation.WatchToPhone
    
    typealias Inbound = Operation.PhoneToWatch
    #endif
    
    var inbound: Inbound? {
        
        #if os(iOS)
        guard case .watchToPhone(let operation) = operation else { return nil }
        #elseif os(watchOS)
        guard case .phoneToWatch(let operation) = operation else { return nil }
        #endif
        
        return operation
    }
}
