//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

///
/// Follows Apple's sample code
/// - Building a workout app for iPhone and iPad (WWDC25)
/// - Build a workout app for Apple Watch (WWDC21)
///
/// Only one workout session can run at a time.
///

import HealthKit
import Observation

@Observable
@MainActor
public final class HKWorkoutManager: NSObject {
    
    public private(set) var state: HKWorkoutSessionState = .notStarted
    
    // MARK: Variables
    
    let healthStore = HKHealthStore()
    
    var session: HKWorkoutSession?
    
    var builder: HKLiveWorkoutBuilder?
    
    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    // Sharing energy and heart rate lets the builder save them with the workout.
    static var typesToShare: Set<HKSampleType> {
        
        [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate)
        ]
    }
    
    static var typesToRead: Set<HKObjectType> {
        
        [
            HKQuantityType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned)
        ]
    }
    
    // MARK: Diagnostics
    
    public private(set) var logEntries: [LogEntry] = []
    
    var collectedCounts: [String: Int] = [:]
    
    var lastSavedWorkout: HKWorkout?
    
    var lastSaveError: String?
    
    public override init() {
        
        super.init()
    }
    
    // MARK: Authorization
    
    public func requestAuthorization() {
        
        log("Asking for Health permission")
        
        Task {
            
            do {
                
                try await healthStore.requestAuthorization(
                    toShare: HKWorkoutManager.typesToShare,
                    read: HKWorkoutManager.typesToRead
                )
                log("Health permission request finished")
            
            } catch {
                
                log("Health permission request failed: \(error.localizedDescription)")
                
            }
        }
    }
    
    // MARK: Controls
    
    public func start() {
        
        guard session == nil else {
            log("Start ignored: a workout session is already in progress")
            return
        }
        
        log("Start")
        
        collectedCounts = [:]
        lastSavedWorkout = nil
        lastSaveError = nil
        
        let configuration = HKWorkoutManager.workoutConfiguration
        
        do {
            
            let newSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            let newBuilder = newSession.associatedWorkoutBuilder()
            
            newSession.delegate = self
            newBuilder.delegate = self
            newBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            
            let collecting = newBuilder.dataSource?.typesToCollect.map { HKWorkoutManager.displayName(of: $0.identifier) } ?? []
            log("Collecting: \(collecting.sorted().joined(separator: ", "))")
            
            session = newSession
            builder = newBuilder
        
        } catch {
            
            log("Failed to create workout session: \(error.localizedDescription)")
            return
            
        }
        
        session?.prepare()
        
        let startDate = Date.now
        session?.startActivity(with: startDate)
        state = .running
        
        Task {
            
            do {
                
                try await builder?.beginCollection(at: startDate)
                log("Began collecting")
            
            } catch {
                
                log("Failed to begin collecting: \(error.localizedDescription)")
                state = .notStarted
                session?.end()
                
            }
        }
    }
    
    public func pause() {
        
        log("Pause")
        session?.pause()
    }
    
    public func resume() {
        
        log("Resume")
        session?.resume()
    }
    
    public func end() {
        
        guard session != nil else {
            log("End ignored: no workout session")
            return
        }
        
        log("End")
        state = .stopped
        session?.stopActivity(with: .now)
    }
    
    // MARK: Session Events
    
    func sessionDidChange(
        _ sessionID: ObjectIdentifier,
        from oldState: HKWorkoutSessionState,
        to state: HKWorkoutSessionState,
        at date: Date
    ) {
        
        guard isCurrentSession(sessionID) else {
            log("Ignored a state change from an old session")
            return
        }
        
        log("Session: \(HKWorkoutManager.describe(oldState)) → \(HKWorkoutManager.describe(state))")
        
        switch state {
        
        case .running:
            self.state = .running
        
        case .paused:
            self.state = .paused
        
        case .stopped:
            finishWorkout(at: date)
        
        case .ended:
            self.state = .ended
            resetSession()
        
        default:
            break
            
        }
    }
    
    func sessionDidFail(_ sessionID: ObjectIdentifier, description: String) {
        
        log("Session failed: \(description)")
        
        guard isCurrentSession(sessionID) else { return }
        
        state = .ended
        session?.end()
        resetSession()
    }
    
    func builderDidCollect(_ typeNames: [String]) {
        
        for name in typeNames {
            collectedCounts[name, default: 0] += 1
        }
    }
    
    // Ignores events from sessions that have already ended.
    private func isCurrentSession(_ sessionID: ObjectIdentifier) -> Bool {
        
        guard let session else { return false }
        return ObjectIdentifier(session) == sessionID
    }
    
    // MARK: Saving
    
    // Saving follows Apple's order: stop, finish collecting, save, then end the session.
    private func finishWorkout(at endDate: Date) {
        
        guard let session, let builder else { return }
        
        Task {
            
            do {
                
                try await builder.endCollection(at: endDate)
                log("Ended collecting")
                
                let workout = try await builder.finishWorkout()
                lastSavedWorkout = workout
                
                if let workout {
                    log("Saved workout with active energy: \(HKWorkoutManager.describeEnergy(of: workout))")
                } else {
                    log("Saving finished but returned no workout")
                }
            
            } catch {
                
                lastSaveError = error.localizedDescription
                log("Failed to save workout: \(error.localizedDescription)")
                
            }
            
            // End the session even if saving failed, so a new one can start.
            log("Ending session")
            session.end()
        }
    }
    
    private func resetSession() {
        
        session = nil
        builder = nil
    }
}
