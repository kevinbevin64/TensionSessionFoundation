//
//  SyncInstruction+Operation.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

extension SyncInstruction {
    
    enum Operation: Codable {
        
        case phoneToWatch(PhoneToWatch)
        
        case watchToPhone(WatchToPhone)
    }
}
