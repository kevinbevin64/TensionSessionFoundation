//
//  ExerciseHistorian+EquipmentMatchingRule.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/1/26.
//

extension ExerciseHistorian {

    enum EquipmentMatchingRule: Hashable {

        case required(Exercise.Equipment)

        case notRequired
    }
}
