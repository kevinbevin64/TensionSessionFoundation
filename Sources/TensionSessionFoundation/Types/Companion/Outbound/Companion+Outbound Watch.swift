//
//  Companion+Outbound Watch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

#if os(watchOS)
public extension Companion {
    
    func requestTemplateWorkoutsHashCheck() {
        
        guard let hash = workoutManager?.getTemplateWorkoutsHash() else {
            assertionFailure()
            return
        }

        sendInstantly(
            .templateWorkoutsHashCheckRequest(hash: hash),
            replyHandler: { self.process($0) }
        )
    }
    
    func requestHistoricalWorkoutsHashCheck() {
        
        guard let hash = workoutManager?.getHistoricalWorkoutsHash() else {
            assertionFailure()
            return
        }

        sendInstantly(
            .historicalWorkoutsHashCheckRequest(hash: hash),
            replyHandler: { self.process($0) }
        )
    }
    
    func requestExerciseCatalogHashCheck() {
        
        guard let hash = getExerciseCatalogDTO?().getHash() else {
            assertionFailure()
            return
        }

        sendInstantly(
            .exerciseCatalogHashCheckRequest(hash: hash),
            replyHandler: { self.process($0) }
        )
    }

    func requestTemplateWorkoutEditApproval(
        former formerWorkout: Workout,
        final finalWorkout: Workout
    ) {

        let formerWorkoutDTO = formerWorkout.getDTO()
        let finalWorkoutDTO = finalWorkout.getDTO()

        guard formerWorkoutDTO.id2 == finalWorkoutDTO.id2 else {
            assertionFailure()
            return
        }

        send(.requestTemplateWorkoutEditApproval(
            former: formerWorkoutDTO,
            final: finalWorkoutDTO
        ))
    }

    func requestUserInfoEditApproval(
        former formerUserInfo: UserInfo,
        final finalUserInfo: UserInfo
    ) {

        send(.requestUserInfoEditApproval(
            former: formerUserInfo.getDTO(),
            final: finalUserInfo.getDTO()
        ))
    }

    func requestUserInfoOverwrite() {

        send(.requestUserInfoOverwrite)
    }
}
#endif // os(watchOS)
