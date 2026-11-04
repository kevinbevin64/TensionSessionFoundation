//
//  Companion+Outbound Phone.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/2/26.
//

#if os(iOS)
public extension Companion {
    
    func addTemplateWorkout(_ workout: Workout) {
        
        send(.addTemplateWorkout(workout: workout.getDTO()))
    }
    
    func editTemplateWorkout(_ workout: Workout) {
        
        send(.editTemplateWorkout(workout: workout.getDTO()))
    }
    
    func deleteTemplateWorkout(_ workout: Workout) {
        
        send(.deleteTemplateWorkout(id2: workout.id2))
    }
    
    func editExerciseCatalog(_ catalog: Exercise.Catalog) {
        
        send(.editExerciseCatalog(catalog: catalog.getDTO()))
    }

    func editUserInfo(_ userInfo: UserInfo) {

        send(.editUserInfo(userInfo: userInfo.getDTO()))
    }
}
#endif // os(iOS)
