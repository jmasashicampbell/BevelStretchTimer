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
        case countdown(endDate: Date)
        case step(index: Int, endDate: Date, sessionStartDate: Date)
        case paused(stepIndex: Int, remaining: TimeInterval, totalElapsed: TimeInterval)
        case done(sessionStartDate: Date)
    }

    private let steps: [StretchStep]
    var phase: Phase = .countdown(endDate: .now + 3)
    private var sessionTask: Task<Void, Never>?

    init(steps: [StretchStep]) {
        self.steps = steps
    }

    var currentStep: StretchStep? {
        switch phase {
        case .step(let index, _, _), .paused(let index, _, _):
            return steps[index]
        default:
            return nil
        }
    }

    var nextStep: StretchStep? {
        switch phase {
        case .step(let index, _, _), .paused(let index, _, _):
            let next = index + 1
            return next < steps.count ? steps[next] : nil
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
        case .step(let index, _, _), .paused(let index, _, _):
            return index > 0
        default:
            return false
        }
    }

    var canSkipForward: Bool {
        switch phase {
        case .step(let index, _, _), .paused(let index, _, _):
            return index < steps.count - 1
        default:
            return false
        }
    }

    // MARK: Public methods

    func start() async {
        let countdownEnd = Date.now + 3
        phase = .countdown(endDate: countdownEnd)
        try? await Task.sleep(for: .seconds(3))
        sessionTask = Task { await runFrom(stepIndex: 0, sessionStartDate: .now) }
    }

    func end() {
        sessionTask?.cancel()
        sessionTask = nil
    }

    func skipBackward() {
        switch phase {
        case .step(let index, _, let sessionStartDate):
            play(index: index - 1, remaining: nil, totalElapsed: Date.now.timeIntervalSince(sessionStartDate))
        case .paused(let index, _, let totalElapsed):
            pause(index: index - 1, remaining: TimeInterval(steps[index - 1].duration), totalElapsed: totalElapsed)
        default:
            break
        }
    }

    func skipForward() {
        switch phase {
        case .step(let index, _, let sessionStartDate):
            play(index: index + 1, remaining: nil, totalElapsed: Date.now.timeIntervalSince(sessionStartDate))
        case .paused(let index, _, let totalElapsed):
            pause(index: index + 1, remaining: TimeInterval(steps[index + 1].duration), totalElapsed: totalElapsed)
        default:
            break
        }
    }

    func resetStep() {
        switch phase {
        case .step(let index, _, let sessionStartDate):
            pause(index: index, remaining: TimeInterval(steps[index].duration), totalElapsed: Date.now.timeIntervalSince(sessionStartDate))
        case .paused(let index, _, let totalElapsed):
            pause(index: index, remaining: TimeInterval(steps[index].duration), totalElapsed: totalElapsed)
        default:
            break
        }
    }

    func togglePause() {
        switch phase {
        case .step(let index, let endDate, let sessionStartDate):
            pause(index: index, remaining: max(0, endDate.timeIntervalSinceNow), totalElapsed: Date.now.timeIntervalSince(sessionStartDate))
        case .paused(let index, let remaining, let totalElapsed):
            play(index: index, remaining: remaining, totalElapsed: totalElapsed)
        default:
            break
        }
    }

    // MARK: Private state changes

    private func play(index: Int,
                      remaining: TimeInterval?,
                      totalElapsed: TimeInterval) {
        sessionTask?.cancel()
        let sessionStartDate = Date.now - totalElapsed
        sessionTask = Task {
            await runFrom(stepIndex: index,
                          initialRemaining: remaining,
                          sessionStartDate: sessionStartDate)
        }
    }

    private func pause(index: Int,
                       remaining: TimeInterval,
                       totalElapsed: TimeInterval) {
        sessionTask?.cancel()
        sessionTask = nil
        phase = .paused(stepIndex: index,
                        remaining: remaining,
                        totalElapsed: totalElapsed)
    }

    private func runFrom(stepIndex: Int,
                         initialRemaining: TimeInterval? = nil,
                         sessionStartDate: Date) async {
        for index in stepIndex..<steps.count {
            let duration: TimeInterval
            if let initialRemaining, index == stepIndex {
                duration = initialRemaining
            } else {
                duration = TimeInterval(steps[index].duration)
            }
            
            phase = .step(index: index,
                          endDate: .now + duration,
                          sessionStartDate: sessionStartDate)
            try? await Task.sleep(for: .seconds(duration))
        }
        phase = .done(sessionStartDate: sessionStartDate)
    }
}
