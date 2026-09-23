//
//  WatchTransferrable.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

protocol WatchTransferrable {
    
    func dictionaryForm() throws -> [String: Any]
    
    init(fromDictionary: [String: Any]) throws
}
