//
//  Companion+Inbound Shared.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import Foundation
import WatchConnectivity

// MARK: Low level

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

// MARK: Called on received message

extension Companion {
    
    func receiveHistoricalWorkout(_ workout: Workout.DTO) {

        guard let workoutManager else {
            assertionFailure()
            return
        }

        workoutManager.addHistoricalWorkout(Workout(fromDTO: workout))
    }

    func receiveHistoricalWorkoutsHashCheckRequest(
        _ senderHash: WorkoutManager.HistoricalWorkoutsHash
    ) -> [String: Any] {

        guard let workoutManager else {
            assertionFailure()
            return [:]
        }

        let receiverHash = workoutManager.getHistoricalWorkoutsHash()
        let hashesMatch = receiverHash == senderHash
        let syncStatus: SyncStatus.HistoricalWorkouts

        if hashesMatch {
            syncStatus = .matched
        } else {
            let receiverHistoricalWorkouts = workoutManager.sortedHistory.map { $0.getDTO() }
            syncStatus = .notMatched(receiverHistoricalWorkouts)
        }

        let operation = SyncInstruction.Outbound.historicalWorkoutsHashCheckReply(
            status: syncStatus
        )
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }

    func receiveHistoricalWorkoutsHashCheckReply(_ syncStatus: SyncStatus.HistoricalWorkouts) {

        guard let workoutManager else {
            assertionFailure()
            return
        }

        guard case .notMatched(let companionHistoricalWorkouts) = syncStatus else {
            return
        }

        let workoutsMissingHere: [Workout.DTO] = companionHistoricalWorkouts.filter { workout in
            let workoutIsPresentHere = workoutManager.unsortedHistory.contains(where: {
                $0.getDTO() == workout
            })

            if workoutIsPresentHere { return false }
            return true
        }

        for workout in workoutsMissingHere {
            workoutManager.addHistoricalWorkout(Workout(fromDTO: workout))
        }
    }
}
