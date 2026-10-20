//
//  SetDetail.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

nonisolated public struct SetDetail: Codable, Sendable {
    
    public var repsDone: Int
    
    public var weightUsed: Weight
    
    public var motionSamples: [RepDetector.MotionSample]?
    
    public var guessedRepCount: Int?
    
    // FIXME: REmove this
    public init(
        repsDone: Int,
        weightUsed: Weight,
        motionSamples: [RepDetector.MotionSample]? = nil,
        guessedRepCount: Int? = nil
    ) {
        self.repsDone = repsDone
        self.weightUsed = weightUsed
        self.motionSamples = motionSamples
        self.guessedRepCount = guessedRepCount
    }
}
