//
//  SetDetail.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

public struct SetDetail: Codable {
    
    public var repsDone: Int
    
    public var weightUsed: Weight
    
    // FIXME: REmove this
    public init(repsDone: Int, weightUsed: Weight) {
        self.repsDone = repsDone
        self.weightUsed = weightUsed
    }
}
