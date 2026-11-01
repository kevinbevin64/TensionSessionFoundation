//
//  ExerciseHistorian+SearchRule.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/1/26.
//

extension ExerciseHistorian {

    struct SearchRule: Hashable {

        let kind: Exercise.Catalog.Kind

        let equipmentMatchingRule: EquipmentMatchingRule
    }
}
