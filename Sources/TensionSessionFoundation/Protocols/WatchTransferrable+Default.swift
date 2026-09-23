//
//  WatchTransferrable+Default.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import Foundation

extension WatchTransferrable where Self: Codable {
    
    func dictionaryForm() throws -> [String: Any] {
        
        let data = try PropertyListEncoder().encode(self)
        
        let object = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        )
        
        guard let dictionary = object as? [String: Any] else {
            throw WatchTransferring.Error.notDictionary
        }
        
        return dictionary
    }
    
    init(fromDictionary dictionary: [String: Any]) throws {
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: dictionary,
            format: .binary,
            options: 0
        )

        self = try PropertyListDecoder().decode(Self.self, from: data)
    }
}

extension Array: WatchTransferrable where Element: Codable & WatchTransferrable {}
