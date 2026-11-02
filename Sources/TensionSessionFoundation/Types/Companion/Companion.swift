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
    
    // MARK: Variables
    
    #if os(iOS)
    public var isPaired: Bool?
    
    public var isWatchAppInstalled: Bool?
    #endif // os(iOS)
    
    #if os(watchOS)
    var requestTemplateWorkoutsHashCheckSchedule: Schedule?
    
    var requestExerciseCatalogHashCheckSchedule: Schedule?
    #endif // os(watchOS)
    
    // MARK: Closures
    
    public var getExerciseCatalogDTO: (() -> Exercise.Catalog.DTO)?
    
    #if os(watchOS)
    public var editCatalog: ((Exercise.Catalog.DTO) -> Void)?
    #endif // os(watchOS)
}
