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
public final class HKWorkoutManager: NSObject {
    
    public private(set) var stage: Stage = .idle
    
    private let healthStore = HKHealthStore()
    
    private var session: HKWorkoutSession?
    
    private var builder: HKLiveWorkoutBuilder?
    
    // What the caller last asked for. The session is moved toward it whenever its state changes.
    private var target: Target = .ended
    
    private enum Target {
        
        case running
        
        case paused
        
        case ended
    }
    
    private static let workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        return configuration
    }()
    
    override init() {
        
        super.init()
    }
    
    // MARK: Controls
    
    func start() {
        
        switch stage {
        case .idle, .errored: break
        default: return
        }
        
        target = .running
        stage = .starting
        
        Task {
            do {
                try await Self.requestAuthorization()
                guard Self.workoutAuthorization == .allowed else { throw Error.notAuthorized }
                
                guard target != .ended else {
                    stage = .idle
                    return
                }
                
                let newSession = try HKWorkoutSession(
                    healthStore: healthStore,
                    configuration: Self.workoutConfiguration
                )
                let newBuilder = newSession.associatedWorkoutBuilder()
                newSession.delegate = self
                newBuilder.delegate = self
                newBuilder.dataSource = HKLiveWorkoutDataSource(
                    healthStore: healthStore,
                    workoutConfiguration: Self.workoutConfiguration
                )
                session = newSession
                builder = newBuilder
                
                let startDate = Date.now
                newSession.startActivity(with: startDate)
                try await newBuilder.beginCollection(at: startDate)
            } catch let error as Error {
                fail(with: error)
            } catch {
                fail(with: .failedToStart(error.localizedDescription))
            }
        }
    }
    
    func pause() {
        
        guard target == .running else { return }
        target = .paused
        moveTowardTarget()
    }
    
    func resume() {
        
        guard target == .paused else { return }
        target = .running
        moveTowardTarget()
    }
    
    func end() {
        
        guard target != .ended else { return }
        target = .ended
        moveTowardTarget()
    }
    
    private func moveTowardTarget() {
        
        guard let session else { return }
        
        switch (stage, target) {
        case (.running, .paused):
            session.pause()
        case (.paused, .running):
            session.resume()
        case (.running, .ended), (.paused, .ended):
            stage = .stopping
            session.stopActivity(with: Date.now)
        default:
            break
        }
    }
    
    // MARK: Session events
    
    func sessionDidChange(
        _ sessionID: ObjectIdentifier,
        to state: HKWorkoutSessionState,
        at date: Date
    ) {
        guard isCurrentSession(sessionID) else { return }
        
        switch state {
        case .running:
            stage = .running
            moveTowardTarget()
        case .paused:
            stage = .paused
            moveTowardTarget()
        case .stopped:
            finishWorkout(at: date)
        case .ended:
            resetSession()
            if case .errored = stage { return }
            stage = .idle
        default:
            break
        }
    }
    
    func sessionDidFail(_ sessionID: ObjectIdentifier, withDescription description: String) {
        
        guard isCurrentSession(sessionID) else { return }
        fail(with: .sessionFailed(description))
    }
    
    private func isCurrentSession(_ sessionID: ObjectIdentifier) -> Bool {
        
        guard let session else { return false }
        return ObjectIdentifier(session) == sessionID
    }
    
    // Saving follows Apple's order: stop, finish collecting, save, then end the session
    private func finishWorkout(at endDate: Date) {
        
        guard let session, let builder else { return }
        
        Task {
            do {
                try await builder.endCollection(at: endDate)
                _ = try await builder.finishWorkout()
            } catch {
                stage = .errored(.failedToSave(error.localizedDescription))
            }
            
            session.end()
        }
    }
    
    private func fail(with error: Error) {
        
        session?.end()
        resetSession()
        target = .ended
        stage = .errored(error)
    }
    
    private func resetSession() {
        
        session = nil
        builder = nil
    }
}
