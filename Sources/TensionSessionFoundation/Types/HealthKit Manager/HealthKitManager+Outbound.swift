//
//  HealthKitManager+Outbound.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/5/26.
//

import HealthKit

// MARK: Authorization

public extension HKWorkoutManager {
    
    func requestAuthorization() {
        
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
}

// MARK: Controls

public extension HKWorkoutManager {
    
    func start() {
        
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
    
    func pause() {
        
        session?.pause()
    }
    
    func resume() {
        
        session?.resume()
    }
    
    func end() {
        
        guard session != nil else { return }
        
        state = .stopped
        session?.stopActivity(with: .now)
    }
}

// MARK: Saving

extension HKWorkoutManager {
    
    // Saving follows Apple's order: stop, finish collecting, save, then end the session.
    func finishWorkout(at endDate: Date) {
        
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
    
    func resetSession() {
        
        session = nil
        builder = nil
    }
}
