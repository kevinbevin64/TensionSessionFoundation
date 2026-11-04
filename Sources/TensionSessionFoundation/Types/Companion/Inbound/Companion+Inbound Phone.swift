//
//  Companion+Inbound Phone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import WatchConnectivity

#if os(iOS)
extension Companion {
    
    nonisolated
    public func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        process(message, replyHandler: replyHandler)
    }

    func process(
        _ operation: SyncInstruction.Inbound,
        replyHandler: (([String: Any]) -> Void)?
    ) {

        let replyHandler: (([String: Any]) -> Void) = replyHandler ?? { [weak self] dictionary in
            self?.send(dictionary: dictionary)
        }

        switch operation {

        case .addHistoricalWorkouts(let workouts):
            receiveHistoricalWorkouts(workouts)

        case .historicalWorkoutsHashCheckRequest(let hash):
            replyHandler(receiveHistoricalWorkoutsHashCheckRequest(hash))

        case .historicalWorkoutsHashCheckReply(let status):
            receiveHistoricalWorkoutsHashCheckReply(status)

        case .templateWorkoutsHashCheckRequest(let hash):
            replyHandler(receiveTemplateWorkoutsHashCheckRequest(hash))

        case .exerciseCatalogHashCheckRequest(let hash):
            replyHandler(receiveExerciseCatalogHashCheckRequest(hash))

        case let .requestTemplateWorkoutEditApproval(former, final):
            replyHandler(receiveTemplateWorkoutEditApprovalRequest(former, final))

        case let .requestUserInfoEditApproval(former, final):
            replyHandler(receiveUserInfoEditApprovalRequest(former, final))

        case .requestUserInfoOverwrite:
            replyHandler(receiveUserInfoOverwriteRequest())

        }
    }
}

extension Companion {

    func receiveHistoricalWorkoutsHashCheckRequest(
        _ watchHash: WorkoutManager.HistoricalWorkoutsHash
    ) -> [String: Any] {

        guard let syncStatus = historicalWorkoutsHashCheckStatus(comparedWith: watchHash) else {
            return [:]
        }

        let operation = SyncInstruction.Outbound.historicalWorkoutsHashCheckReply(status: syncStatus)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }

    func receiveTemplateWorkoutsHashCheckRequest(
        _ watchHash: WorkoutManager.TemplateWorkoutsHash
    ) -> [String: Any] {
        
        guard let workoutManager else {
            assertionFailure()
            return [:]
        }

        let phoneHash = workoutManager.getTemplateWorkoutsHash()
        let hashesMatch = watchHash == phoneHash
        let syncStatus: SyncStatus.TemplateWorkouts
        
        if hashesMatch {
            syncStatus = .matched
        } else {
            syncStatus = .notMatched(workoutManager.sortedTemplates.map { $0.getDTO() })
        }

        let operation = SyncInstruction.Outbound.templateWorkoutsHashCheckReply(status: syncStatus)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }
    
    func receiveExerciseCatalogHashCheckRequest(
        _ watchHash: Exercise.Catalog.DTO.Hash
    ) -> [String: Any] {
        
        guard let catalog = getExerciseCatalogDTO?() else {
            assertionFailure()
            return [:]
        }

        let phoneHash = catalog.getHash()
        let hashesMatch = watchHash == phoneHash
        let syncStatus: SyncStatus.ExerciseCatalog
        
        if hashesMatch {
            syncStatus = .matched
        } else {
            syncStatus = .notMatched(catalog)
        }

        let operation = SyncInstruction.Outbound.exerciseCatalogHashCheckReply(status: syncStatus)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }

    func receiveTemplateWorkoutEditApprovalRequest(
        _ formerWorkout: Workout.DTO,
        _ finalWorkout: Workout.DTO
    ) -> [String: Any] {

        guard let workoutManager else {
            assertionFailure()
            return [:]
        }

        let approvalStatus: ApprovalStatus.TemplateWorkout

        if let phoneWorkout = workoutManager.unsortedTemplates.first(
            where: { $0.id2 == formerWorkout.id2 }
        ) {

            let phoneWorkoutDTO = phoneWorkout.getDTO()
            let approved = formerWorkout.id2 == phoneWorkoutDTO.id2
                && formerWorkout.name == phoneWorkoutDTO.name
                && formerWorkout.state == phoneWorkoutDTO.state
                && formerWorkout.startInstant == phoneWorkoutDTO.startInstant
                && formerWorkout.sortedExercises == phoneWorkoutDTO.sortedExercises

            if approved {
                workoutManager.editTemplate(accordingTo: Workout(fromDTO: finalWorkout))
                approvalStatus = .approved(finalWorkout)
            } else {
                approvalStatus = .denied(phoneWorkoutDTO)
            }

        } else {
            approvalStatus = .nonexistent(id2: formerWorkout.id2)
        }

        let operation = SyncInstruction.Outbound.templateWorkoutEditApproval(status: approvalStatus)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }

    func receiveUserInfoEditApprovalRequest(
        _ formerUserInfo: UserInfo.DTO,
        _ finalUserInfo: UserInfo.DTO
    ) -> [String: Any] {

        guard let phoneUserInfo = getUserInfo?() else {
            assertionFailure()
            return [:]
        }

        let approved = formerUserInfo == phoneUserInfo
        let approvalStatus: ApprovalStatus.UserInfo

        if approved {
            editUserInfo?(finalUserInfo)
            approvalStatus = .approved(finalUserInfo)
        } else {
            approvalStatus = .denied(phoneUserInfo)
        }

        let operation = SyncInstruction.Outbound.userInfoEditApproval(status: approvalStatus)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }

    func receiveUserInfoOverwriteRequest() -> [String: Any] {

        guard let phoneUserInfo = getUserInfo?() else {
            assertionFailure()
            return [:]
        }

        let operation = SyncInstruction.Outbound.userInfoEditOverwrite(userInfo: phoneUserInfo)
        let dictionary = try? SyncInstruction(operation).dictionaryForm()
        guard let dictionary else {
            assertionFailure()
            return [:]
        }

        return dictionary
    }
}
#endif // os(iOS)
