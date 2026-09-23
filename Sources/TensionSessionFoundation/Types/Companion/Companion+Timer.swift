//
//  Companion+Timer.swift
//  TensionSession
//
//  Created by Kevin on 9/16/26.
//

#if os(watchOS)
public extension Companion {
    
    func startTimer(_ duration: Duration, action: @escaping @MainActor () -> Void) {
        timerTask?.cancel()
        timerAction = action
        timerTask = makeTimerTask(duration: duration)
    }
    
    func rewindTimer(to duration: Duration) {
        guard timerTask != nil, timerAction != nil else { return }
        timerTask?.cancel()
        timerTask = makeTimerTask(duration: duration)
    }
    
    private func makeTimerTask(duration: Duration) -> Task<Void, Never> {
        Task {
            do {
                try await Task.sleep(for: duration)
            } catch {
                return
            }
            
            let action = timerAction
            timerTask = nil
            timerAction = nil
            action?()
        }
    }
}
#endif // os(watchOS)
