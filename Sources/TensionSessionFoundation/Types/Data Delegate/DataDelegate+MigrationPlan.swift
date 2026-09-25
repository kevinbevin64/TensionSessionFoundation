//
//  DataDelegate+MigrationPlan.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

import SwiftData

enum CurrentStore: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [
            WorkoutManager.self,
            Workout.self,
            Exercise.self,
            UserInfo.self,
            Exercise.Catalog.self
        ]
    }
}

enum DataDelegateMigrationPlan: SchemaMigrationPlan {
    
    static var schemas: [any VersionedSchema.Type] {
        [
            OldStore.self,
            CurrentStore.self
        ]
    }
    
    static var stages: [MigrationStage] {
        [oldStoreToCurrentStore]
    }
    
    static let oldStoreToCurrentStore = MigrationStage.custom(
        fromVersion: OldStore.self,
        toVersion: CurrentStore.self,
        willMigrate: { context in
            try OldStoreMigration.prepare(context)
        },
        didMigrate: { context in
            try OldStoreMigration.finish(context)
        }
    )
}
