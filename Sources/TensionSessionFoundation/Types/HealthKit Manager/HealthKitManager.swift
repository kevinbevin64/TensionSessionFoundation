//
//  HealthKitManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 9/1/26.
//

import HealthKit
import Observation

@Observable
@MainActor
public final class HKWorkoutManager: NSObject {
    
    public private(set) var state: HKWorkoutSessionState = .notStarted
    
    // MARK: Variables
    
    private let healthStore = HKHealthStore()
    
    private var session: HKWorkoutSession?
    
    private var builder: HKLiveWorkoutBuilder?
    
    private var isStoppingSession = false
    
    private var pendingStartDate: Date?
    
    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    override init() {
        
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
    
    func start() {
        
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
            pendingStartDate = startDate
        }
    }
    
    func pause() {
        
        guard state == .running else { return }
        
        state = .paused
        
        guard let session, !isStoppingSession, session.state == .running else { return }
        session.pause()
    }
    
    func resume() {
        
        guard state == .paused else { return }
        
        state = .running
        
        guard let session, !isStoppingSession, session.state == .paused else { return }
        session.resume()
    }
    
    func end() {
        
        guard state == .running || state == .paused else { return }
        
        state = .ended
        pendingStartDate = nil
        
        guard let session, session.state == .running || session.state == .paused else { return }
        stopSession()
    }
    
    func selectionDidReset() {
        
        if state == .ended {
            state = .notStarted
        }
    }
    
    private var canSaveWorkouts: Bool {
        
        healthStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }
    
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
            stopFollowingSelection()
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
                
                newSession.end()
                resetSession()
                stopFollowingSelection()
                
            }
        }
    }
    
    private func stopSession() {
        
        guard let session, !isStoppingSession else { return }
        
        isStoppingSession = true
        session.stopActivity(with: .now)
    }
    
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
        
        if isStoppingSession {
            session.end()
            resetSession()
            startPendingSessionIfNeeded()
            return
        }
        
        isStoppingSession = true
        stopFollowingSelection()
        finishWorkout(at: .now)
    }
    
    private func stopFollowingSelection() {
        
        pendingStartDate = nil
        
        if state == .running || state == .paused {
            state = .notStarted
        }
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
            
            guard isCurrentSession(ObjectIdentifier(session)) else { return }
            resetSession()
            startPendingSessionIfNeeded()
        }
    }
    
    private func resetSession() {
        
        session = nil
        builder = nil
        isStoppingSession = false
    }
}
