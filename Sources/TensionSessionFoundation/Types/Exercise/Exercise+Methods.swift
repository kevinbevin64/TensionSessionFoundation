//
//  Exercise+Methods.swift
//  TensionSession
//
//  Created by Kevin Chen on 8/22/26.
//

@MainActor
public extension Exercise {
    
    func completeSet(
        repsDone: Int,
        weightUsed: Weight,
        motionSamples: [RepDetector.MotionSample]? = nil,
        guessedRepCount: Int? = nil
    ) {
        let newSet = SetDetail(
            repsDone: repsDone,
            weightUsed: weightUsed,
            motionSamples: motionSamples,
            guessedRepCount: guessedRepCount
        )
        self.setDetails.append(newSet)
    }
    
    func removeLastSet() {
        
        assert(setDetails.isEmpty == false)
        setDetails.removeLast()
    }
    
    func removeSet(at index: Int) {
        
        assert(index < setDetails.count)
        setDetails.remove(at: index)
    }
}
