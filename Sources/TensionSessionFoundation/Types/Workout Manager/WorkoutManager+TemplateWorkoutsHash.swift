//
//  WorkoutManager+TemplateWorkoutsHash.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/16/26.
//

import Foundation

public extension WorkoutManager {
    
    struct TemplateWorkoutsHash: Codable, Equatable, WatchTransferrable {
        
        public var digest: Data
        
        public init(digest: Data) {
            self.digest = digest
        }
        
        public var hexString: String {
            digest.map { String(format: "%02x", $0) }.joined()
        }
    }
}
