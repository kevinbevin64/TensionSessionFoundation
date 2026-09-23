//
//  WorkoutManager.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import Foundation
import SwiftData

@Model
public final class WorkoutManager {
    
    @Transient
    public var sortedTemplates: [Workout] {
        unsortedTemplates.sorted { $0.order < $1.order }
    }
    
    @Transient
    public lazy var sortedHistory: [Workout] = {
        return unsortedHistory.sorted {
            
            guard let firstInstant = $0.startInstant,
                  let secondInstant = $1.startInstant else {
                assertionFailure()
                return true
            }
            
            return firstInstant > secondInstant
        }
    }()
    
    @Relationship(deleteRule: .cascade)
    public var unsortedTemplates: [Workout]
    
    @Relationship(deleteRule: .cascade)
    var unsortedHistory: [Workout]
    
    @Transient
    var save: () throws -> Void = {}
    
    @Transient
    @MainActor
    public var templateBuffer: TemplateBuffer {
        get {
            if let backingTemplateBuffer {
                return backingTemplateBuffer
            } else {
                let templateBuffer = TemplateBuffer() { id2 in
                    if self.sortedTemplates.contains(where: { $0.id2 == id2 }) {
                        self.lastUsedId2 = id2
                    }
                } onEmptying: {
                    self.lastUsedId2 = nil
                }
                if let freshTemplate = freshTemplate(){
                    templateBuffer.insert(freshTemplate)
                }
                backingTemplateBuffer = templateBuffer
                return templateBuffer
            }
        }
    }
    
    @Transient
    @MainActor
    private var backingTemplateBuffer: TemplateBuffer?
    
    @Transient
    @MainActor
    var lastUsedId2: UUID?
    
    @Transient
    @MainActor
    var companion: Companion?
    
    init(
        templates: [Workout],
        history: [Workout],
    ) {
        self.unsortedTemplates = templates
        self.unsortedHistory = history
    }
    
    init() {
        self.unsortedTemplates = []
        self.unsortedHistory = []
    }
}
