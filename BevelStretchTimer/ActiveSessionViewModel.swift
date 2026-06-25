//
//  ActiveSessionViewModel.swift
//  BevelStretchTimer
//

import Observation
import Foundation

@MainActor
@Observable
class ActiveSessionViewModel {
    enum Phase {
        case countdown(Int)
        case step(index: Int, endDate: Date)
        case paused(stepIndex: Int, remaining: TimeInterval)
        case done
    }

    private let steps: [StretchStep]
    var phase: Phase = .countdown(3)
    private var sessionTask: Task<Void, Never>?

    init(steps: [StretchStep]) {
        self.steps = steps
    }

    var currentStep: StretchStep? {
        switch phase {
        case .step(let index, _), .paused(let index, _):
            return steps[index]
        default:
            return nil
        }
    }

    var isPaused: Bool {
        if case .paused = phase { return true }
        return false
    }

    var canSkipBackward: Bool {
        switch phase {
        case .step(let index, _), .paused(let index, _):
            return index > 0
        default:
            return false
        }
    }

    var canSkipForward: Bool {
        switch phase {
        case .step(let index, _), .paused(let index, _):
            return index < steps.count - 1
        default:
            return false
        }
    }

    func start() async {
        do {
            for count in [3, 2, 1] {
                phase = .countdown(count)
                try await Task.sleep(for: .seconds(1))
            }
            sessionTask = Task { await runFrom(stepIndex: 0) }
        } catch {
            // cancelled on pause or view dismissal
        }
    }

    func end() {
        sessionTask?.cancel()
        sessionTask = nil
    }
    
    func play(index: Int, remaining: TimeInterval?) {
        sessionTask?.cancel()
        sessionTask = Task { await runFrom(stepIndex: index, initialRemaining: remaining) }
    }
    
    func pause(index: Int, remaining: TimeInterval) {
        sessionTask?.cancel()
        sessionTask = nil
        phase = .paused(stepIndex: index, remaining: remaining)
    }

    func skipBackward() {
        switch phase {
        case .step(let index, _):
            play(index: index - 1,
                 remaining: nil)
        case .paused(let index, _):
            pause(index: index - 1,
                  remaining: TimeInterval(steps[index - 1].duration))
        default:
            break
        }
    }

    func skipForward() {
        switch phase {
        case .step(let index, _):
            play(index: index + 1,
                 remaining: nil)
        case .paused(let index, _):
            pause(index: index + 1,
                  remaining: TimeInterval(steps[index + 1].duration))
        default:
            break
        }
    }

    func resetStep() {
        switch phase {
        case .step(let index, _), .paused(let index, _):
            pause(index: index, remaining: TimeInterval(steps[index].duration))
        default:
            break
        }
    }

    func togglePause() {
        switch phase {
        case .step(let index, let endDate):
            pause(index: index, remaining: max(0, endDate.timeIntervalSinceNow))
        case .paused(let index, let remaining):
            play(index: index, remaining: remaining)
        default:
            break
        }
    }

    private func runFrom(stepIndex: Int, initialRemaining: TimeInterval? = nil) async {
        do {
            for index in stepIndex..<steps.count {
                var duration: TimeInterval
                if let initialRemaining, index == stepIndex {
                    duration = initialRemaining
                } else {
                    duration = TimeInterval(steps[index].duration)
                }
                phase = .step(index: index, endDate: .now + duration)
                try await Task.sleep(for: .seconds(duration))
            }
            phase = .done
        } catch {
            // cancelled on pause or view dismissal
        }
    }
}
