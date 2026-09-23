//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

import Foundation
import HealthKit
import Observation

@Observable
@MainActor
class HKWorkoutManager: NSObject {
    
    static let shared = HKWorkoutManager()
    
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    private static let shareTypes: Set = [
        HKQuantityType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.heartRate)
    ]
    
    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    override init() {
        super.init()
    }
    
    func start() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Ensure no active session exists before initializing
        guard session == nil && builder == nil else { return }
        
        Task {
            do {
                // 1. Request Authorization
                try await healthStore.requestAuthorization(toShare: Self.shareTypes, read: [])
                
                // 2. Initialize Session and Builder
                let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: Self.workoutConfiguration)
                let newBuilder = newSession.associatedWorkoutBuilder()
                
                newSession.delegate = self
                newBuilder.delegate = self
                newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: Self.workoutConfiguration)
                
                self.session = newSession
                self.builder = newBuilder
                
                // 3. Start Data Collection
                let startDate = Date.now
                newSession.startActivity(with: startDate)
                try await newBuilder.beginCollection(at: startDate)
                
            } catch {
                print("Failed to start workout session: \(error.localizedDescription)")
                resetSession()
            }
        }
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func end() {
        guard let session = session, let builder = builder else { return }
        
        Task {
            let endDate = Date.now
            session.end()
            
            do {
                try await builder.endCollection(at: endDate)
                _ = try await builder.finishWorkout()
                print("Successfully saved workout to HealthKit.")
            } catch {
                print("Failed to gracefully close or save workout: \(error.localizedDescription)")
            }
            
            resetSession()
        }
    }
    
    private func resetSession() {
        self.session = nil
        self.builder = nil
    }
}

// MARK: - HKWorkoutSessionDelegate
extension HKWorkoutManager: HKWorkoutSessionDelegate {
    
    // 1. Mark nonisolated so HealthKit's background thread can enter without crashing
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("HKWorkoutSession changed state: \(toState.rawValue)")
        
        if toState == .ended {
            // 2. Hop back to the MainActor safely to update properties
            Task { @MainActor in
                self.resetSession()
            }
        }
    }
    
    // 1. Mark nonisolated here too
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("HKWorkoutSession failed with error: \(error.localizedDescription)")
        
        // 2. Hop back to the MainActor safely
        Task { @MainActor in
            self.resetSession()
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    // 1. Mark nonisolated to handle events arriving on HealthKit's background queue
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {}
}
