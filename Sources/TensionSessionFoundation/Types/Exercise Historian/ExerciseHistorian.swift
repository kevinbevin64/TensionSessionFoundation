//
//  ExerciseHistorian.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/1/26.
//

import DequeModule
import Foundation

@Observable
public class ExerciseHistorian {

    private static let maxConcurrentSearches = 3

    private static let workoutsPerYield = 50

    private weak var workoutManager: WorkoutManager?

    private var sortedExerciseHistories: [SearchRule: [HistoricalExercise]]

    private var inFlightSearches: [SearchRule: Task<[HistoricalExercise], Never>]

    private var runningSearchCount: Int

    private var waitingSearches: Deque<CheckedContinuation<Void, Never>>

    init(workoutManager: WorkoutManager) {

        self.workoutManager = workoutManager
        self.sortedExerciseHistories = [:]
        self.inFlightSearches = [:]
        self.runningSearchCount = 0
        self.waitingSearches = Deque()
    }

    public func getSortedExerciseHistory(
        forKind kind: Exercise.Catalog.Kind,
        equipmentMatchingRule: EquipmentMatchingRule
    ) async -> [HistoricalExercise] {
        let searchRule = SearchRule(
            kind: kind,
            equipmentMatchingRule: equipmentMatchingRule
        )

        if let sortedExerciseHistory = sortedExerciseHistories[searchRule] {
            return sortedExerciseHistory
        }

        if let inFlightSearch = inFlightSearches[searchRule] {
            return await inFlightSearch.value
        }

        let search = Task {
            await acquireSearchSlot()
            defer { releaseSearchSlot() }
            return await searchHistory(for: searchRule)
        }

        inFlightSearches[searchRule] = search

        let sortedExerciseHistory = await search.value

        sortedExerciseHistories[searchRule] = sortedExerciseHistory
        inFlightSearches[searchRule] = nil

        return sortedExerciseHistory
    }

    public func adjust(accordingTo newlyCompletedWorkout: Workout) {

        // FIXME: Make this fine-grained
        // Invalidating the dictionary is okay for now and achieves the same end result

        sortedExerciseHistories = [:]
    }

    private func searchHistory(for searchRule: SearchRule) async -> [HistoricalExercise] {

        guard let workoutManager else { preconditionFailure() }

        var sortedExerciseHistory: [HistoricalExercise] = []

        for (index, historicalWorkout) in workoutManager.sortedHistory.enumerated() {

            if index > 0, index.isMultiple(of: Self.workoutsPerYield) {
                await Task.yield()
            }

            guard let startInstant = historicalWorkout.startInstant else {
                assertionFailure()
                continue
            }

            guard let exercise = historicalWorkout.exerciseMatching(searchRule: searchRule) else {
                continue
            }

            sortedExerciseHistory.append(
                HistoricalExercise(
                    startInstant: startInstant,
                    exercise: exercise
                )
            )
        }

        return sortedExerciseHistory
    }

    private func acquireSearchSlot() async {

        if runningSearchCount < Self.maxConcurrentSearches {
            runningSearchCount += 1
            return
        }

        await withCheckedContinuation { continuation in
            waitingSearches.append(continuation)
        }
    }

    private func releaseSearchSlot() {

        assert(runningSearchCount > 0)

        if let nextSearch = waitingSearches.popFirst() {
            nextSearch.resume()
        } else {
            runningSearchCount -= 1
        }
    }
}
