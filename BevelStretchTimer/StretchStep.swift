//
//  StretchStep.swift
//  BevelStretchTimer
//

import Foundation

struct StretchStep: Identifiable {
    let id = UUID()
    var name: String
    var duration: Int  // seconds

    init(name: String = "", duration: Int = 15) {
        self.name = name
        self.duration = duration
    }
}
