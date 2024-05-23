//
//  Item.swift
//  8cube
//
//  Created by Sam Roman on 5/22/24.
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
