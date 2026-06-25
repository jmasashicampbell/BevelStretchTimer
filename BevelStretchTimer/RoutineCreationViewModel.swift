//
//  RoutineCreationViewModel.swift
//  BevelStretchTimer
//

import Observation
import Foundation

@Observable
class RoutineCreationViewModel {
    var routine = StretchRoutine()
    var didAttemptStart = false

    var totalDuration: Int {
        routine.steps.reduce(0) { $0 + $1.duration }
    }

    var validationError: String? {
        if routine.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Your routine needs a title"
        }
        if routine.steps.contains(where: { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }) {
            return "You have a step missing a title"
        }
        if routine.steps.contains(where: { $0.duration == 0 }) {
            return "You have a missing time input"
        }
        return nil
    }

    func addStep() {
        routine.steps.append(StretchStep())
    }

    func deleteStep(id: UUID) {
        routine.steps.removeAll { $0.id == id }
    }
}
