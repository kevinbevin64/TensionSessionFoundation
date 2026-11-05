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
    
    private let healthStore = HKHealthStore()
    
    private var session: HKWorkoutSession?
    
    private var builder: HKLiveWorkoutBuilder?
    
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
    
    public func requestAuthorization() {
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned)
        ]
        
        Task {
            
            do {
                
                try await healthStore.requestAuthorization(
                    toShare: typesToShare,
                    read: typesToRead
                )
            
            } catch {
                
                print("Failed to request authorization: \(error.localizedDescription)")
                
            }
        }
    }
    
    // MARK: Controls
    
    public func start() {
        
        guard session == nil else {
            print("A workout session is already in progress.")
            return
        }
        
        let configuration = Self.workoutConfiguration
        
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
            
            session = newSession
            builder = newBuilder
        
        } catch {
            
            print("Failed to create workout session: \(error.localizedDescription)")
            return
            
        }
        
        session?.prepare()
        
        let startDate = Date.now
        session?.startActivity(with: startDate)
        state = .running
        
        Task {
            
            do {
                
                try await builder?.beginCollection(at: startDate)
            
            } catch {
                
                print("Failed to start workout: \(error.localizedDescription)")
                state = .notStarted
                session?.end()
                
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
        
        guard session != nil else { return }
        
        state = .stopped
        session?.stopActivity(with: .now)
    }
    
    // MARK: Session Events
    
    func sessionDidChange(
        _ sessionID: ObjectIdentifier,
        to state: HKWorkoutSessionState,
        at date: Date
    ) {
        
        guard isCurrentSession(sessionID) else { return }
        
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
    
    func sessionDidFail(_ sessionID: ObjectIdentifier) {
        
        guard isCurrentSession(sessionID) else { return }
        
        state = .ended
        session?.end()
        resetSession()
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
                _ = try await builder.finishWorkout()
            
            } catch {
                
                print("Failed to save workout: \(error.localizedDescription)")
                
            }
            
            // End the session even if saving failed, so a new one can start.
            session.end()
        }
    }
    
    private func resetSession() {
        
        session = nil
        builder = nil
    }
}
