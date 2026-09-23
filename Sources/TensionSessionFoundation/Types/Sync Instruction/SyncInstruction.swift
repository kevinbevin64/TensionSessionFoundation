//
//  SyncInstruction.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

import SwiftData

nonisolated
public struct SyncInstruction: Sendable {
    
    var operation: Operation
    
    var payload: [String: any Sendable]
    
    nonisolated
    init(operationOnly operation: Operation) {
        self.operation = operation
        self.payload = [:]
    }
    
    nonisolated
    init(operation: Operation, payload: [String: Any]) {
        self.operation = operation
        self.payload = payload as! [String: any Sendable]
    }
    
    nonisolated
    init(_ operation: Operation, _ payload: [String: Any]) {
        self.operation = operation
        self.payload = payload as! [String: any Sendable]
    }
}
