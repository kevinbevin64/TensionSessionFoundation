//
//  ApprovalStatus+UserInfo.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/3/26.
//

extension ApprovalStatus {

    enum UserInfo: Codable & WatchTransferrable {

        case approved

        case denied(TensionSessionFoundation.UserInfo.DTO)
    }
}
