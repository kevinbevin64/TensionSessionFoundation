//
//  Exercise+GoalAdvancement.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/17/26.
//

public extension Exercise {

    var isGoalAdvancementCriteriaMet: Bool {

        guard setsPlanned > 0, setDetails.count >= setsPlanned else {
            return false
        }

        let tolerance = 0.01

        return setDetails.prefix(setsPlanned).allSatisfy { setDetail in
            let weightUsed = setDetail.weightUsed.converted(to: weightPlanned.unit)
            return setDetail.repsDone >= repsPlanned
                && weightUsed.value >= weightPlanned.value - tolerance
        }
    }
}
