//
//  WorkoutGenerator+Stage.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 10/12/26.
//

#if os(iOS)
public extension WorkoutGenerator {
    
    enum Stage {
        
        case ready
        case active
        case done(Workout, String)
        case errored(Error)

        public var caseIndex: Int {

            switch self {
            case .ready: return 0
            case .active: return 1
            case .done: return 2
            case .errored: return 3
            }
        }
    }
}
#endif
