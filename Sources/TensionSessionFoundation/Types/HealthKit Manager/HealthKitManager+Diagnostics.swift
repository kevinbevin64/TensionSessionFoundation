//
//  HealthKitManager+Diagnostics.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 11/5/26.
//

import HealthKit

// MARK: Types

public extension HKWorkoutManager {
    
    struct LogEntry: Identifiable {
        
        public let id = UUID()
        
        public let date: Date
        
        public let message: String
    }
    
    struct DiagnosticSection: Identifiable {
        
        public var id: String { title }
        
        public let title: String
        
        public let rows: [DiagnosticRow]
    }
    
    struct DiagnosticRow: Identifiable {
        
        public let id = UUID()
        
        public let label: String
        
        public let value: String
    }
}

// MARK: Log

extension HKWorkoutManager {
    
    func log(_ message: String) {
        
        print("[HealthKit] \(message)")
        
        logEntries.append(LogEntry(date: .now, message: message))
        
        if logEntries.count > 300 {
            logEntries.removeFirst(logEntries.count - 300)
        }
    }
}

// MARK: Snapshot

public extension HKWorkoutManager {
    
    func makeDiagnostics() async -> [DiagnosticSection] {
        
        [
            await permissionsSection(),
            sessionSection(),
            builderSection(),
            await healthSamplesSection(),
            lastSavedWorkoutSection(),
            await latestWorkoutInHealthSection()
        ]
    }
    
    private func permissionsSection() async -> DiagnosticSection {
        
        var rows: [DiagnosticRow] = [
            DiagnosticRow(
                label: "Health data available",
                value: HKHealthStore.isHealthDataAvailable() ? "Yes" : "No"
            )
        ]
        
        do {
            
            let requestStatus = try await healthStore.statusForAuthorizationRequest(
                toShare: HKWorkoutManager.typesToShare,
                read: HKWorkoutManager.typesToRead
            )
            rows.append(DiagnosticRow(label: "Permission prompt", value: HKWorkoutManager.describe(requestStatus)))
        
        } catch {
            
            rows.append(DiagnosticRow(label: "Permission prompt", value: "Error: \(error.localizedDescription)"))
            
        }
        
        for type in HKWorkoutManager.typesToShare.sorted(by: { $0.identifier < $1.identifier }) {
            rows.append(
                DiagnosticRow(
                    label: "Save \(HKWorkoutManager.displayName(of: type.identifier))",
                    value: HKWorkoutManager.describe(healthStore.authorizationStatus(for: type))
                )
            )
        }
        
        rows.append(DiagnosticRow(label: "Read access", value: "Apple hides this from apps"))
        
        return DiagnosticSection(title: "Permissions", rows: rows)
    }
    
    private func sessionSection() -> DiagnosticSection {
        
        var rows: [DiagnosticRow] = [
            DiagnosticRow(label: "Manager state", value: HKWorkoutManager.describe(state))
        ]
        
        if let session {
            rows.append(DiagnosticRow(label: "Session state", value: HKWorkoutManager.describe(session.state)))
            rows.append(DiagnosticRow(label: "Started", value: HKWorkoutManager.describe(session.startDate)))
            rows.append(DiagnosticRow(label: "Activity", value: "\(session.workoutConfiguration.activityType.rawValue) (strength training is 50)"))
            rows.append(DiagnosticRow(label: "Location", value: session.workoutConfiguration.locationType == .indoor ? "Indoor" : "Not indoor"))
        } else {
            rows.append(DiagnosticRow(label: "Session", value: "None"))
        }
        
        return DiagnosticSection(title: "Session", rows: rows)
    }
    
    private func builderSection() -> DiagnosticSection {
        
        guard let builder else {
            return DiagnosticSection(
                title: "Live data",
                rows: [DiagnosticRow(label: "Builder", value: "None")]
            )
        }
        
        var rows: [DiagnosticRow] = [
            DiagnosticRow(label: "Data source", value: builder.dataSource == nil ? "Missing" : "Set"),
            DiagnosticRow(label: "Builder started", value: HKWorkoutManager.describe(builder.startDate)),
            DiagnosticRow(label: "Elapsed", value: "\(Int(builder.elapsedTime)) s"),
            DiagnosticRow(label: "Events", value: "\(builder.workoutEvents.count)")
        ]
        
        let collecting = builder.dataSource?.typesToCollect.map { HKWorkoutManager.displayName(of: $0.identifier) } ?? []
        rows.append(DiagnosticRow(label: "Collecting", value: collecting.isEmpty ? "Nothing" : collecting.sorted().joined(separator: ", ")))
        
        let energy = builder.statistics(for: HKQuantityType(.activeEnergyBurned))
        rows.append(DiagnosticRow(label: "Active energy", value: HKWorkoutManager.describeEnergy(energy)))
        
        let heartRate = builder.statistics(for: HKQuantityType(.heartRate))
        rows.append(DiagnosticRow(label: "Heart rate now", value: HKWorkoutManager.describeHeartRate(heartRate?.mostRecentQuantity())))
        rows.append(DiagnosticRow(label: "Heart rate avg", value: HKWorkoutManager.describeHeartRate(heartRate?.averageQuantity())))
        
        if collectedCounts.isEmpty {
            rows.append(DiagnosticRow(label: "Updates received", value: "None yet"))
        } else {
            for (name, count) in collectedCounts.sorted(by: { $0.key < $1.key }) {
                rows.append(DiagnosticRow(label: "Updates: \(name)", value: "\(count)"))
            }
        }
        
        for (type, statistics) in builder.allStatistics.sorted(by: { $0.key.identifier < $1.key.identifier }) {
            let quantity = statistics.sumQuantity() ?? statistics.mostRecentQuantity()
            rows.append(
                DiagnosticRow(
                    label: "All stats: \(HKWorkoutManager.displayName(of: type.identifier))",
                    value: quantity?.description ?? "No value"
                )
            )
        }
        
        return DiagnosticSection(title: "Live data", rows: rows)
    }
    
    private func healthSamplesSection() async -> DiagnosticSection {
        
        let start = builder?.startDate ?? session?.startDate ?? Date.now.addingTimeInterval(-30 * 60)
        
        var rows: [DiagnosticRow] = [
            DiagnosticRow(label: "Since", value: HKWorkoutManager.describe(start))
        ]
        
        for type in [HKQuantityType(.activeEnergyBurned), HKQuantityType(.heartRate)] {
            
            let name = HKWorkoutManager.displayName(of: type.identifier)
            
            let descriptor = HKSampleQueryDescriptor(
                predicates: [
                    .quantitySample(
                        type: type,
                        predicate: HKQuery.predicateForSamples(withStart: start, end: nil)
                    )
                ],
                sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]
            )
            
            do {
                
                let samples = try await descriptor.result(for: healthStore)
                
                let sources = Set(samples.map { $0.sourceRevision.source.name }).sorted()
                
                rows.append(DiagnosticRow(label: "\(name) samples", value: "\(samples.count)"))
                
                if type == HKQuantityType(.activeEnergyBurned) {
                    let total = samples.reduce(0) { $0 + $1.quantity.doubleValue(for: .kilocalorie()) }
                    rows.append(DiagnosticRow(label: "\(name) total", value: String(format: "%.1f kcal", total)))
                } else {
                    rows.append(DiagnosticRow(label: "\(name) latest", value: HKWorkoutManager.describeHeartRate(samples.first?.quantity)))
                }
                
                rows.append(DiagnosticRow(label: "\(name) from", value: sources.isEmpty ? "No one" : sources.joined(separator: ", ")))
            
            } catch {
                
                rows.append(DiagnosticRow(label: "\(name) samples", value: "Error: \(error.localizedDescription)"))
                
            }
        }
        
        rows.append(DiagnosticRow(label: "Note", value: "Zero can also mean read access is off"))
        
        return DiagnosticSection(title: "In Health right now", rows: rows)
    }
    
    private func lastSavedWorkoutSection() -> DiagnosticSection {
        
        var rows: [DiagnosticRow] = []
        
        if let lastSaveError {
            rows.append(DiagnosticRow(label: "Save error", value: lastSaveError))
        }
        
        if let lastSavedWorkout {
            rows.append(contentsOf: HKWorkoutManager.describeRows(of: lastSavedWorkout))
        } else if lastSaveError == nil {
            rows.append(DiagnosticRow(label: "Saved workout", value: "None this launch"))
        }
        
        return DiagnosticSection(title: "Last save (this launch)", rows: rows)
    }
    
    private func latestWorkoutInHealthSection() async -> DiagnosticSection {
        
        let descriptor = HKSampleQueryDescriptor(
            predicates: [
                .workout(HKQuery.predicateForObjects(from: HKSource.default()))
            ],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        
        do {
            
            guard let workout = try await descriptor.result(for: healthStore).first else {
                return DiagnosticSection(
                    title: "Latest workout in Health",
                    rows: [DiagnosticRow(label: "Workout", value: "None found (or read access is off)")]
                )
            }
            
            return DiagnosticSection(
                title: "Latest workout in Health",
                rows: HKWorkoutManager.describeRows(of: workout)
            )
        
        } catch {
            
            return DiagnosticSection(
                title: "Latest workout in Health",
                rows: [DiagnosticRow(label: "Error", value: error.localizedDescription)]
            )
            
        }
    }
}

// MARK: Descriptions

extension HKWorkoutManager {
    
    nonisolated
    static func displayName(of identifier: String) -> String {
        
        switch identifier {
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue: return "Active energy"
        case HKQuantityTypeIdentifier.basalEnergyBurned.rawValue: return "Resting energy"
        case HKQuantityTypeIdentifier.heartRate.rawValue: return "Heart rate"
        case HKObjectType.workoutType().identifier: return "Workouts"
        default: return identifier.replacingOccurrences(of: "HKQuantityTypeIdentifier", with: "")
        }
    }
    
    nonisolated
    static func describe(_ state: HKWorkoutSessionState) -> String {
        
        switch state {
        case .notStarted: return "Not started"
        case .prepared: return "Prepared"
        case .running: return "Running"
        case .paused: return "Paused"
        case .stopped: return "Stopped"
        case .ended: return "Ended"
        @unknown default: return "Unknown (\(state.rawValue))"
        }
    }
    
    nonisolated
    static func describe(_ type: HKWorkoutEventType) -> String {
        
        switch type {
        case .pause: return "Pause"
        case .resume: return "Resume"
        case .lap: return "Lap"
        case .marker: return "Marker"
        case .motionPaused: return "Motion paused"
        case .motionResumed: return "Motion resumed"
        case .segment: return "Segment"
        case .pauseOrResumeRequest: return "Pause or resume request"
        @unknown default: return "Unknown (\(type.rawValue))"
        }
    }
    
    static func describe(_ status: HKAuthorizationStatus) -> String {
        
        switch status {
        case .notDetermined: return "Not asked"
        case .sharingDenied: return "Denied"
        case .sharingAuthorized: return "Allowed"
        @unknown default: return "Unknown (\(status.rawValue))"
        }
    }
    
    static func describe(_ status: HKAuthorizationRequestStatus) -> String {
        
        switch status {
        case .unknown: return "Unknown"
        case .shouldRequest: return "Not shown yet"
        case .unnecessary: return "Already answered"
        @unknown default: return "Unknown (\(status.rawValue))"
        }
    }
    
    static func describe(_ date: Date?) -> String {
        
        guard let date else { return "None" }
        return date.formatted(date: .omitted, time: .standard)
    }
    
    static func describeEnergy(_ statistics: HKStatistics?) -> String {
        
        guard let quantity = statistics?.sumQuantity() else { return "None" }
        return String(format: "%.1f kcal", quantity.doubleValue(for: .kilocalorie()))
    }
    
    static func describeEnergy(of workout: HKWorkout) -> String {
        
        describeEnergy(workout.statistics(for: HKQuantityType(.activeEnergyBurned)))
    }
    
    static func describeHeartRate(_ quantity: HKQuantity?) -> String {
        
        guard let quantity else { return "None" }
        return String(format: "%.0f bpm", quantity.doubleValue(for: .count().unitDivided(by: .minute())))
    }
    
    static func describeRows(of workout: HKWorkout) -> [DiagnosticRow] {
        
        var rows: [DiagnosticRow] = [
            DiagnosticRow(label: "Started", value: describe(workout.startDate)),
            DiagnosticRow(label: "Ended", value: describe(workout.endDate)),
            DiagnosticRow(label: "Duration", value: "\(Int(workout.duration)) s"),
            DiagnosticRow(label: "Active energy", value: describeEnergy(of: workout)),
            DiagnosticRow(
                label: "Heart rate avg",
                value: describeHeartRate(workout.statistics(for: HKQuantityType(.heartRate))?.averageQuantity())
            ),
            DiagnosticRow(label: "Events", value: "\(workout.workoutEvents?.count ?? 0)"),
            DiagnosticRow(label: "Activities", value: "\(workout.workoutActivities.count)")
        ]
        
        let statisticNames = workout.allStatistics.keys.map { displayName(of: $0.identifier) }.sorted()
        rows.append(DiagnosticRow(label: "Has stats for", value: statisticNames.isEmpty ? "Nothing" : statisticNames.joined(separator: ", ")))
        
        return rows
    }
}
