//
//  ApprovalStatus+TemplateWorkout.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/3/26.
//

import Foundation

extension ApprovalStatus {

    enum TemplateWorkout: Codable & WatchTransferrable {

        case approved(Workout.DTO)

        case denied(Workout.DTO)

        case nonexistent(id2: UUID)
    }
}
