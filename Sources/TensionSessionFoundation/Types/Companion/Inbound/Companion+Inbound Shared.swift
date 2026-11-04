//
//  Companion+Inbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import Foundation
import WatchConnectivity

extension Companion {
    
    nonisolated
    public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        process(message)
    }
    
    nonisolated
    public func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any]
    ) {
        process(userInfo)
    }
    
    nonisolated
    func process(
        _ dictionary: [String: Any],
        replyHandler: (([String: Any]) -> Void)? = nil
    ) {
        
        nonisolated(unsafe) let dictionary = dictionary
        nonisolated(unsafe) let replyHandler = replyHandler
        
        DispatchQueue.main.async { [weak self] in

            guard let instruction = try? SyncInstruction(fromDictionary: dictionary),
                  let operation = instruction.inbound else
            {
                return
            }
            
            #if os(iOS)
            self?.process(operation, replyHandler: replyHandler)
            #elseif os(watchOS)
            self?.process(operation)
            #endif
        }
    }
}

extension Companion {
    
    func receiveHistoricalWorkout(_ workout: Workout.DTO) {
        
        workoutManager?.addHistoricalWorkout(Workout(fromDTO: workout))
    }
    
    func historicalWorkoutsHashCheckStatus(
        comparedWith hash: WorkoutManager.HistoricalWorkoutsHash
    ) -> SyncStatus.HistoricalWorkouts? {
        
        guard let workoutManager else {
            assertionFailure()
            return nil
        }
        
        if hash == workoutManager.getHistoricalWorkoutsHash() {
            return .matched
        } else {
            return .notMatched(workoutManager.sortedHistory.map { $0.getDTO() })
        }
    }
    
    func receiveHistoricalWorkoutsHashCheckReply(_ syncStatus: SyncStatus.HistoricalWorkouts) {
        
        guard case .notMatched(let counterpartWorkouts) = syncStatus,
              let workoutManager else {
            return
        }
        
        let missingOnCounterpart = workoutManager.unsortedHistory.filter {
            counterpartWorkouts.contains($0.getDTO()) == false
        }
        
        for workout in counterpartWorkouts {
            workoutManager.addHistoricalWorkout(Workout(fromDTO: workout))
        }
        
        for workout in missingOnCounterpart {
            addHistoricalWorkout(workout)
        }
    }
}
