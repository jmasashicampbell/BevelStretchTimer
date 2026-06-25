//
//  Item.swift
//  BevelStretchTimer
//
//  Created by Bevel Work Trial 12 on 6/25/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
