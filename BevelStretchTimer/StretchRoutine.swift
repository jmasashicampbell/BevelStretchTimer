//
//  StretchRoutine.swift
//  BevelStretchTimer
//

import Foundation

struct StretchRoutine {
    var name: String
    var steps: [StretchStep]

    init(name: String = "", steps: [StretchStep] = [StretchStep()]) {
        self.name = name
        self.steps = steps
    }
}
