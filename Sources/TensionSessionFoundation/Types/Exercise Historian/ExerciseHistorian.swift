//
//  ExerciseHistorian.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/1/26.
//

import Foundation

class ExerciseHistorian {

    private weak var workoutManager: WorkoutManager?

    private var sortedExerciseHistories: [SearchRule: [HistoricalExercise]]

    init(workoutManager: WorkoutManager) {
        self.sortedExerciseHistories = [:]
        self.workoutManager = workoutManager
    }

    func getSortedExerciseHistory(
        forKind kind: Exercise.Catalog.Kind,
        equipmentMatchingRule: EquipmentMatchingRule
    ) -> [HistoricalExercise] {

        guard let workoutManager else { preconditionFailure() }

        let searchRule = SearchRule(
            kind: kind,
            equipmentMatchingRule: equipmentMatchingRule
        )

        if let sortedExerciseHistory = sortedExerciseHistories[searchRule] {
            return sortedExerciseHistory
        }

        let sortedExerciseHistory: [HistoricalExercise]
            = workoutManager.sortedHistory.compactMap { historicalWorkout in

            guard let startInstant = historicalWorkout.startInstant else {
                assertionFailure()
                return nil
            }

            guard let exercise = historicalWorkout.exerciseMatching(searchRule: searchRule) else {
                return nil
            }

            return HistoricalExercise(startInstant: startInstant, exercise: exercise)
        }

        sortedExerciseHistories[searchRule] = sortedExerciseHistory

        return sortedExerciseHistory
    }
}
