//
//  Item.swift
//  Fluentpro
//
//  Created by Alex Wood on 30/5/2025.
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
