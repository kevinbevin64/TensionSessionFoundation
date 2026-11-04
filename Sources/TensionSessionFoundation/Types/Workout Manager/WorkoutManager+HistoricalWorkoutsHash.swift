//
//  WorkoutManager+HistoricalWorkoutsHash.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/4/26.
//

import Foundation

public extension WorkoutManager {
    
    struct HistoricalWorkoutsHash: Codable, Equatable, WatchTransferrable {
        
        public var digest: Data
        
        public init(digest: Data) {
            self.digest = digest
        }
        
        public var hexString: String {
            digest.map { String(format: "%02x", $0) }.joined()
        }
    }
}
