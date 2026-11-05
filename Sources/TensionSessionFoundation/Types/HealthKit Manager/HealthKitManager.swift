//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

import Foundation
import HealthKit
import Observation

// Follows Apple's "Building a workout app for iPhone and iPad" (WWDC25) and
// "Build a workout app for Apple Watch" (WWDC21) samples.
@Observable
@MainActor
public final class HKWorkoutManager: NSObject {

    // Created in the nonisolated session delegate, so it can't be main-actor isolated.
    nonisolated struct SessionStateChange: Sendable {
        let newState: HKWorkoutSessionState
        let date: Date
    }

    public private(set) var state: HKWorkoutSessionState = .notStarted

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    // Keeps only the newest state change, so state changes are handled one at a time and in order.
    let stateChanges = AsyncStream.makeStream(of: SessionStateChange.self, bufferingPolicy: .bufferingNewest(1))

    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()

    public override init() {
        super.init()
        Task {
            for await change in stateChanges.stream {
                await consumeSessionStateChange(change)
            }
        }
    }

    // MARK: - Authorization

    public func requestAuthorization() {
        // The types to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned)
        ]

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
    }

    // MARK: - State Control

    public func start() {
        let configuration = Self.workoutConfiguration

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("Failed to create workout session: \(error)")
            return
        }

        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.prepare()

        Task {
            do {
                // Start the workout session and begin data collection.
                let startDate = Date()
                session?.startActivity(with: startDate)
                state = .running
                try await builder?.beginCollection(at: startDate)
            } catch {
                print("Failed to start workout: \(error)")
                state = .notStarted
            }
        }
    }

    public func pause() {
        session?.pause()
    }

    public func resume() {
        session?.resume()
    }

    public func end() {
        state = .stopped
        session?.stopActivity(with: .now)
    }

    // MARK: - Session State Changes

    // Saving follows Apple's order: stop, finish collecting, save, then end the session.
    private func consumeSessionStateChange(_ change: SessionStateChange) async {
        guard change.newState == .stopped, let builder else { return }

        do {
            try await builder.endCollection(at: change.date)
            _ = try await builder.finishWorkout()
            session?.end()
        } catch {
            print("Error finishing workout: \(error)")
            return
        }
        state = .ended
        resetWorkout()
    }

    private func resetWorkout() {
        builder = nil
        session = nil
    }
}
