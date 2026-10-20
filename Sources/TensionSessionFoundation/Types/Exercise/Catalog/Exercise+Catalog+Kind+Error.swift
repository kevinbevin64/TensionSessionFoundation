//
//  Exercise+Catalog+Kind+Error.swift
//  TensionSession
//
//  Created by Kevin on 9/17/26.
//

public extension Exercise.Catalog.Kind {
    
    enum Error: Swift.Error {
        
        case invalidTrimmedAndNeatenedName
    }
}
