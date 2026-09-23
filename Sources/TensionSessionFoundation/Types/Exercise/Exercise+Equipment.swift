//
//  Exercise+Equipment.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

public extension Exercise {
    
    enum Equipment: String, Codable, CaseIterable {
        
        case dumbbell
        case barbell
        case kettlebell
        case machine
        case cable
        case bodyweight
        
        public var displayName: String {
            switch self {
            case .dumbbell: "Dumbbell"
            case .barbell: "Barbell"
            case .kettlebell: "Kettlebell"
            case .machine: "Machine"
            case .cable: "Cable"
            case .bodyweight: "Bodyweight"
            }
        }
    }
}
