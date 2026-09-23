//
//  Exercise.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

import Foundation
import SwiftData

@Model
public final class Exercise {
    
    public var id2: UUID
    
    public var order: Int
    
    public var kind: Catalog.Kind
    
    public var equipment: Equipment
    
    public var setsPlanned: Int
    
    public var repsPlanned: Int
    
    public var weightPlanned: Weight
    
    public var setDetails: [SetDetail]
    
    init(
        id2: UUID,
        order: Int,
        kind: Catalog.Kind,
        equipment: Equipment,
        setsPlanned: Int,
        repsPlanned: Int,
        weightPlanned: Weight,
        setDetails: [SetDetail]
    ) {
        self.id2 = id2
        self.order = order
        self.kind = kind
        self.equipment = equipment
        self.setsPlanned = setsPlanned
        self.repsPlanned = repsPlanned
        self.weightPlanned = weightPlanned
        self.setDetails = setDetails
    }
    
    public init(
        order: Int,
        kind: Catalog.Kind,
        equipment: Equipment,
        setsPlanned: Int,
        repsPlanned: Int,
        weightPlanned: Weight
    ) {
        self.id2 = UUID()
        self.order = order
        self.kind = kind
        self.equipment = equipment
        self.setsPlanned = setsPlanned
        self.repsPlanned = repsPlanned
        self.weightPlanned = weightPlanned
        self.setDetails = []
    }
}
