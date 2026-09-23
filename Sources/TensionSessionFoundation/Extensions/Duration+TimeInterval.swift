//
//  Duration+TimeInterval.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/25/26.
//

import Foundation

public extension Duration {
    
    var timeInterval: TimeInterval {
        let components = self.components
        return TimeInterval(components.seconds) + TimeInterval(components.attoseconds) / 1e18
    }
}
