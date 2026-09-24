//
//  FirstRepCounter.swift
//  TensionSessionFoundation
//
//  Created by Kevin on 9/24/26.
//

extension RepDetector {

    public struct RepCounter1: RepCounter {

        private struct FilteredSample {
            let timestamp: TimeInterval
            let magnitude: Double
        }

        private struct MovementCycle {
            let start: TimeInterval
            let end: TimeInterval
            let peak: Double
        }

        // Magnitudes are in g. Durations are in seconds.
        private enum Repetition {
            static let smoothingWindow = 5
            static let cycleOnset = 0.30
            static let cycleRelease = 0.15
            static let minimumPeak = 0.40
            static let minimumDuration: TimeInterval = 0.40
            static let maximumDuration: TimeInterval = 8
        }

        public static func getRepCount(in samples: [MotionSample]) -> Int {

            guard samples.count > 1 else {
                return 0
            }

            // 1. Filter the signal
            let signal = filterSignal(samples)

            // 2. Find movement cycles
            let cycles = movementCycles(in: signal)

            // 3. Validate each cycle as a repetition
            // 4. Return the number of repetitions
            return cycles.filter { isRepetition($0) }.count
        }

        private static func magnitude(of sample: MotionSample) -> Double {
            (sample.x * sample.x + sample.y * sample.y + sample.z * sample.z).squareRoot()
        }

        private static func filterSignal(_ samples: [MotionSample]) -> [FilteredSample] {

            let magnitudes = samples.map { magnitude(of: $0) }
            let smoothed = movingAverage(magnitudes, window: Repetition.smoothingWindow)

            return zip(samples, smoothed).map { sample, magnitude in
                FilteredSample(timestamp: sample.timestamp, magnitude: magnitude)
            }
        }

        private static func movingAverage(_ values: [Double], window: Int) -> [Double] {

            var smoothed: [Double] = []
            smoothed.reserveCapacity(values.count)
            var sum = 0.0

            for index in values.indices {
                sum += values[index]
                if index >= window {
                    sum -= values[index - window]
                }
                let count = min(index + 1, window)
                smoothed.append(sum / Double(count))
            }

            return smoothed
        }

        private static func movementCycles(in signal: [FilteredSample]) -> [MovementCycle] {

            var cycles: [MovementCycle] = []
            var cycleStart: TimeInterval?
            var peak = 0.0

            for sample in signal {
                if let start = cycleStart {
                    peak = max(peak, sample.magnitude)

                    if sample.magnitude <= Repetition.cycleRelease {
                        cycles.append(
                            MovementCycle(start: start, end: sample.timestamp, peak: peak)
                        )
                        cycleStart = nil
                        peak = 0
                    }
                } else if sample.magnitude >= Repetition.cycleOnset {
                    cycleStart = sample.timestamp
                    peak = sample.magnitude
                }
            }

            if let cycleStart, let last = signal.last {
                cycles.append(
                    MovementCycle(start: cycleStart, end: last.timestamp, peak: peak)
                )
            }

            return cycles
        }

        private static func isRepetition(_ cycle: MovementCycle) -> Bool {

            let duration = cycle.end - cycle.start
            return cycle.peak >= Repetition.minimumPeak
                && duration >= Repetition.minimumDuration
                && duration <= Repetition.maximumDuration
        }
    }
}
