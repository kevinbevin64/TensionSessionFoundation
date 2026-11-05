//
//  SyncInstruction.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

public struct SyncInstruction: Codable {
    
    var operation: Operation
    
    init(_ operation: Outbound) {
        
        #if os(iOS)
        self.operation = .phoneToWatch(operation)
        #elseif os(watchOS)
        self.operation = .watchToPhone(operation)
        #endif
    }
}
