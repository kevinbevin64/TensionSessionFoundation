//
//  ExerciseHistorian+SearchRule.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/1/26.
//

public extension ExerciseHistorian {

    struct SearchRule: Hashable {

        let kind: Exercise.Catalog.Kind

        let equipmentMatchingRule: EquipmentMatchingRule
    }
}
