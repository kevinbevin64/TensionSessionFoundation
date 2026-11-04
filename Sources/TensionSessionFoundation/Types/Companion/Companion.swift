//
//  Companion.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/27/26.
//

import WatchConnectivity

@Observable
@MainActor
public final class Companion: NSObject, WCSessionDelegate {

    // MARK: Shared

    public var workoutManager: WorkoutManager?
    
    public var isActive: Bool {
        
        #if os(iOS)
        // Ensure the properties stay in sync
        assert({
            if isReachable == nil
                || isPaired == nil
                || isWatchAppInstalled == nil
            {
                if isReachable != nil
                    || isPaired != nil
                    || isWatchAppInstalled != nil
                {
                    return false
                }
                return true
            }
            return true
        }())
        #endif // os(iOS)
        
        return isReachable != nil
    }

    public var isReachable: Bool?

    public var getExerciseCatalogDTO: (() -> Exercise.Catalog.DTO)?

    public var editUserInfo: ((UserInfo.DTO) -> Void)?

    var requestHistoricalWorkoutsHashCheckSchedule: Schedule?

    #if os(iOS) // MARK: iOS

    public var isPaired: Bool?

    public var isWatchAppInstalled: Bool?

    public var getUserInfo: (() -> UserInfo.DTO)?

    #elseif os(watchOS) // MARK: watchOS

    var requestTemplateWorkoutsHashCheckSchedule: Schedule?
    
    var requestExerciseCatalogHashCheckSchedule: Schedule?

    public var editCatalog: ((Exercise.Catalog.DTO) -> Void)?

    #endif // os(watchOS)
}
