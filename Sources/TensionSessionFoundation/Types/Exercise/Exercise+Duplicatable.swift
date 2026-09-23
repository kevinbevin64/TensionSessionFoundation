//
//  Exercise+Duplicatable.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import Foundation

extension Exercise: Duplicatable {
    
    func duplicated() -> Exercise {
        
        return Exercise(
            id2: UUID(),
            order: order,
            kind: kind,
            equipment: equipment,
            setsPlanned: setsPlanned,
            repsPlanned: repsPlanned,
            weightPlanned: weightPlanned,
            setDetails: setDetails
        )
    }
}

extension [Exercise]: Duplicatable {
    
    func duplicated() -> [Exercise] {
        
        return self.map { exercise in
            exercise.duplicated()
        }
    }
}
