//
//  Weight+CustomStringConvertible.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/24/26.
//

import Foundation

nonisolated extension Weight {
    
    public var unitString: String {
        if value == 1.0 {
            return unit.displayName.singular
        } else {
            return unit.displayName.plural
        }
    }
    
    public var valueString: String {
        String(format: "%.1f", value)
    }
}
