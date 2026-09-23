//
//  Exercise+Catalog+Error.swift
//  TensionSession
//
//  Created by Kevin on 9/17/26.
//

extension Exercise.Catalog {
    
    enum Error: Swift.Error {
        
        case nameDoesNotExist
        
        case nameAlreadyExists
    }
}
