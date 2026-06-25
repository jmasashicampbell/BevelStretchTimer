//
//  RoutineCreationViewModel.swift
//  BevelStretchTimer
//

import Observation
import Foundation

@Observable
class RoutineCreationViewModel {
    var routine = StretchRoutine()

    var totalDuration: Int {
        routine.steps.reduce(0) { $0 + $1.duration }
    }

    func addStep() {
        routine.steps.append(StretchStep())
    }

    func deleteStep(id: UUID) {
        routine.steps.removeAll { $0.id == id }
    }
}
