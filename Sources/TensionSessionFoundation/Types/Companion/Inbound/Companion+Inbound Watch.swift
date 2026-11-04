//
//  Companion+Inbound Watch.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

import Foundation

#if os(watchOS)
extension Companion {
    
    func process(_ operation: SyncInstruction.Inbound) {
        
        switch operation {
            
        case .addTemplateWorkout(let workout):
            receiveNewTemplate(workout)
            
        case .editTemplateWorkout(let workout):
            receiveEditedTemplate(workout)
            
        case .deleteTemplateWorkout(let id2):
            receiveTemplateToBeDeleted(id2)
            
        case .templateWorkoutsHashCheckReply(let status):
            receiveTemplateWorkoutsHashCheckReply(status)
            
        case .exerciseCatalogHashCheckReply(let status):
            receiveExerciseCatalogHashCheckReply(status)
            
        case .editExerciseCatalog(let catalog):
            receiveEditedCatalog(catalog)

        case .templateWorkoutEditApproval(status: let status):
            receiveTemplateWorkoutEditApproval(status)

        case .editUserInfo(let userInfo):
            receiveEditedUserInfo(userInfo)

        case .userInfoEditApproval(status: let status):
            receiveUserInfoEditApproval(status)

        case .userInfoEditOverwrite(userInfo: let userInfo):
            receiveUserInfoOverwrite(userInfo)

        case .addHistoricalWorkouts(let workouts):
            receiveHistoricalWorkouts(workouts)

        case .historicalWorkoutsHashCheckReply(let status):
            receiveHistoricalWorkoutsHashCheckReply(status)
        }
    }
    
    func receiveNewTemplate(_ workout: Workout.DTO) {
        
        workoutManager?.addWorkout(Workout(fromDTO: workout))
    }
    
    func receiveEditedTemplate(_ workout: Workout.DTO) {
        
        workoutManager?.editTemplate(accordingTo: Workout(fromDTO: workout))
    }
    
    func receiveTemplateToBeDeleted(_ id2: UUID) {
        
        guard let workout = workoutManager?.unsortedTemplates.first(
            where: { $0.id2 == id2 }
        ) else {
            return
        }
        
        workoutManager?.deleteTemplate(workout)
    }
    
    func receiveHistoricalWorkouts(_ workouts: [Workout.DTO]) {
        
        workoutManager?.addHistoricalWorkouts(workouts.map { Workout(fromDTO: $0) })
    }
    
    func receiveHistoricalWorkoutsHashCheckReply(_ syncStatus: SyncStatus.HistoricalWorkouts) {
        
        guard case .notMatched(let phoneWorkouts) = syncStatus,
              let workoutManager else {
            return
        }
        
        let missingOnPhone = workoutManager.unsortedHistory.filter {
            phoneWorkouts.contains($0.getDTO()) == false
        }
        
        workoutManager.addHistoricalWorkouts(phoneWorkouts.map { Workout(fromDTO: $0) })
        addHistoricalWorkouts(missingOnPhone)
    }
    
    func receiveTemplateWorkoutsHashCheckReply(_ syncStatus: SyncStatus.TemplateWorkouts) {
        
        guard case .notMatched(let workouts) = syncStatus else { return }
        
        workoutManager?.overwriteTemplates(workouts.map { Workout(fromDTO: $0) })
    }
    
    func receiveExerciseCatalogHashCheckReply(_ syncStatus: SyncStatus.ExerciseCatalog) {
        
        guard case .notMatched(let catalog) = syncStatus else { return }
        
        editCatalog?(catalog)
    }
    
    func receiveEditedCatalog(_ catalog: Exercise.Catalog.DTO) {
        
        editCatalog?(catalog)
    }

    func receiveTemplateWorkoutEditApproval(_ approvalStatus: ApprovalStatus.TemplateWorkout) {

        switch approvalStatus {

        case .approved(let workout):
            workoutManager?.editTemplate(accordingTo: Workout(fromDTO: workout))

        case .denied(let workout):
            workoutManager?.editTemplate(accordingTo: Workout(fromDTO: workout))

        case .nonexistent(id2: let id2):
            guard let workout = workoutManager?.unsortedTemplates.first(
                where: { $0.id2 == id2 }
            ) else {
                return
            }

            workoutManager?.deleteTemplate(workout)
        }
    }

    func receiveEditedUserInfo(_ userInfo: UserInfo.DTO) {

        editUserInfo?(userInfo)
    }

    func receiveUserInfoEditApproval(_ approvalStatus: ApprovalStatus.UserInfo) {

        switch approvalStatus {

        case .approved(let userInfo):
            editUserInfo?(userInfo)

        case .denied(let userInfo):
            editUserInfo?(userInfo)
        }
    }

    func receiveUserInfoOverwrite(_ userInfo: UserInfo.DTO) {

        editUserInfo?(userInfo)
    }
}
#endif // os(watchOS)
