//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

import HealthKit
import Observation

/// Runs the HealthKit workout session for the selected workout.
///
/// `state` follows the selection in `TemplateBuffer`: it changes only through
/// `start()`, `pause()`, `resume()` and `end()`, and the HealthKit session is
/// kept in line with it. If the user hasn't allowed saving workouts, no
/// session runs and `state` stays `.notStarted`.
@Observable
@MainActor
public final class HKWorkoutManager: NSObject {
    
    public private(set) var state: HKWorkoutSessionState = .notStarted
    
    // MARK: Variables
    
    private let healthStore = HKHealthStore()
    
    private var session: HKWorkoutSession?
    
    private var builder: HKLiveWorkoutBuilder?
    
    /// Whether the current session has been told to stop or end.
    private var isStoppingSession = false
    
    /// Start date of a workout waiting for the previous session to finish saving.
    private var pendingStartDate: Date?
    
    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    public override init() {
        
        super.init()
    }
    
    // MARK: Authorization
    
    public func requestAuthorization() async {
        
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.heartRate)
        ]
        
        let typesToRead: Set = [
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.heartRate)
        ]
        
        do {
            
            try await healthStore.requestAuthorization(
                toShare: typesToShare,
                read: typesToRead
            )
        
        } catch {
            
            print("Failed to request authorization: \(error.localizedDescription)")
            
        }
    }
    
    // MARK: Controls
    
    /// Starts a workout. Ignored while a workout is running or paused.
    ///
    /// If the user hasn't allowed saving workouts, no session runs and
    /// `state` stays `.notStarted`.
    public func start() {
        
        guard state != .running, state != .paused else {
            print("A workout is already in progress.")
            return
        }
        
        guard canSaveWorkouts else {
            print("Not allowed to save workouts, so the workout session won't run.")
            state = .notStarted
            return
        }
        
        state = .running
        let startDate = Date.now
        
        if session == nil {
            beginSession(at: startDate)
        } else {
            // The previous workout is still being saved. The new session
            // starts once that one has ended.
            pendingStartDate = startDate
        }
    }
    
    /// Pauses the workout. Does nothing unless it is running.
    public func pause() {
        
        guard state == .running else { return }
        
        state = .paused
        
        guard let session, !isStoppingSession, session.state == .running else { return }
        session.pause()
    }
    
    /// Resumes the workout. Does nothing unless it is paused.
    public func resume() {
        
        guard state == .paused else { return }
        
        state = .running
        
        guard let session, !isStoppingSession, session.state == .paused else { return }
        session.resume()
    }
    
    /// Ends the workout. Does nothing unless it is running or paused.
    public func end() {
        
        guard state == .running || state == .paused else { return }
        
        state = .ended
        pendingStartDate = nil
        
        // A session that hasn't reached `.running` yet is stopped as soon
        // as it does, in `syncSession`.
        guard let session, session.state == .running || session.state == .paused else { return }
        stopSession()
    }
    
    /// Called by `TemplateBuffer` when its selection is replaced or cleared,
    /// so an ended workout goes back to `.notStarted` like the new selection.
    func selectionDidReset() {
        
        if state == .ended {
            state = .notStarted
        }
    }
    
    private var canSaveWorkouts: Bool {
        
        healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }
    
    // MARK: Session
    
    private func beginSession(at startDate: Date) {
        
        let configuration = HKWorkoutManager.workoutConfiguration
        let newSession: HKWorkoutSession
        
        do {
            
            newSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
        
        } catch {
            
            print("Failed to create workout session: \(error.localizedDescription)")
            return
            
        }
        
        let newBuilder = newSession.associatedWorkoutBuilder()
        newSession.delegate = self
        newBuilder.delegate = self
        newBuilder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session = newSession
        builder = newBuilder
        isStoppingSession = false
        
        newSession.prepare()
        newSession.startActivity(with: startDate)
        
        Task {
            
            do {
                
                try await newBuilder.beginCollection(at: startDate)
            
            } catch {
                
                print("Failed to start workout: \(error.localizedDescription)")
                
                guard isCurrentSession(ObjectIdentifier(newSession)) else { return }
                isStoppingSession = true
                newSession.end()
                
            }
        }
    }
    
    private func stopSession() {
        
        guard let session, !isStoppingSession else { return }
        
        isStoppingSession = true
        session.stopActivity(with: .now)
    }
    
    /// Brings a running or paused session in line with `state`.
    private func syncSession(_ session: HKWorkoutSession, currentlyIn sessionState: HKWorkoutSessionState) {
        
        guard !isStoppingSession else { return }
        
        switch state {
        
        case .running where sessionState == .paused:
            session.resume()
        
        case .paused where sessionState == .running:
            session.pause()
        
        case .running, .paused:
            break
        
        default:
            // The workout ended before the session caught up.
            stopSession()
            
        }
    }
    
    private func startPendingSessionIfNeeded() {
        
        guard let startDate = pendingStartDate else { return }
        pendingStartDate = nil
        
        guard state == .running || state == .paused else { return }
        beginSession(at: startDate)
    }
    
    // MARK: Session Events
    
    func sessionDidChange(
        _ sessionID: ObjectIdentifier,
        to sessionState: HKWorkoutSessionState,
        at date: Date
    ) {
        
        guard isCurrentSession(sessionID), let session else { return }
        
        switch sessionState {
        
        case .running, .paused:
            syncSession(session, currentlyIn: sessionState)
        
        case .stopped:
            finishWorkout(at: date)
        
        case .ended:
            resetSession()
            startPendingSessionIfNeeded()
        
        default:
            break
            
        }
    }
    
    func sessionDidFail(_ sessionID: ObjectIdentifier) {
        
        guard isCurrentSession(sessionID), let session else { return }
        
        session.end()
        resetSession()
        startPendingSessionIfNeeded()
    }
    
    private func isCurrentSession(_ sessionID: ObjectIdentifier) -> Bool {
        
        guard let session else { return false }
        return ObjectIdentifier(session) == sessionID
    }
    
    // MARK: Saving
    
    private func finishWorkout(at endDate: Date) {
        
        guard let session, let builder else { return }
        
        Task {
            
            do {
                
                try await builder.endCollection(at: endDate)
                _ = try await builder.finishWorkout()
            
            } catch {
                
                print("Failed to save workout: \(error.localizedDescription)")
                
            }
            
            session.end()
        }
    }
    
    private func resetSession() {
        
        session = nil
        builder = nil
        isStoppingSession = false
    }
}
