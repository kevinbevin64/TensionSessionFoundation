//
//  UserInfo.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

import SwiftData

@Model
public final class UserInfo {
    
    public var restSeconds: Int
    
    public var hasLearnedTimeKeeper: Bool
    
    public var hasWatchCompletedInitialSync: Bool
    
    init(
        restSeconds: Int = 120,
        hasLearnedTimeKeeper: Bool = false,
        hasWatchCompletedInitialSync: Bool = false
    ) {
        self.restSeconds = restSeconds
        self.hasLearnedTimeKeeper = hasLearnedTimeKeeper
        self.hasWatchCompletedInitialSync = hasWatchCompletedInitialSync
    }
}
