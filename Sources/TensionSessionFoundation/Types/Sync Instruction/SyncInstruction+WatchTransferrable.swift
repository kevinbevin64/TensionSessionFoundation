//
//  SyncInstruction+WatchTransferrable.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/8/26.
//

extension SyncInstruction: WatchTransferrable {
    
    nonisolated
    func dictionaryForm() throws -> [String: Any] {
        
        return [
            "operation": operation.rawValue,
            "payload": payload
        ]
    }
    
    nonisolated
    init(fromDictionary dictionary: [String: Any]) throws {
        
        guard let rawOperation = dictionary["operation"] as? String,
              let operation = Operation(rawValue: rawOperation),
              let payload = dictionary["payload"] as? [String: Any]
        else {
            throw Error.initFromDictionaryError
        }
        
        self.init(
            operation: operation,
            payload: payload as! [String: any Sendable]
        )
    }
}
