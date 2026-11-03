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

        case .editUserInfo(let userInfo):
            receiveEditedUserInfo(userInfo)

        case .userInfoEditApproval(status: let status):
            receiveUserInfoEditApproval(status)

        case .userInfoEditOverwrite(userInfo: let userInfo):
            receiveUserInfoOverwrite(userInfo)
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

    func receiveEditedUserInfo(_ userInfo: UserInfo.DTO) {

        editUserInfo?(userInfo)
    }

    func receiveUserInfoEditApproval(_ approvalStatus: ApprovalStatus.UserInfo) {

        if case .denied(let userInfo) = approvalStatus {

            editUserInfo?(userInfo)
        }
    }

    func receiveUserInfoOverwrite(_ userInfo: UserInfo.DTO) {

        editUserInfo?(userInfo)
    }
}
#endif // os(watchOS)
