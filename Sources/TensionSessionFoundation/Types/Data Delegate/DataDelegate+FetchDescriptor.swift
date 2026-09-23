//
//  DataDelegate+FetchDescriptor.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/23/26.
//

import SwiftData

public extension DataDelegate {
    
    static let workoutManagerFetchDescriptor = FetchDescriptor<WorkoutManager>()
    
    static let userInfoFetchDescriptor = FetchDescriptor<UserInfo>()
    
    static let exerciseCatalogFetchDescriptor = FetchDescriptor<Exercise.Catalog>()
}
