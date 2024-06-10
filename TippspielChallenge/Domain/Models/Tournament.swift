//
//  Tournament.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Foundation

struct Tournament: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let from: Date
    let to: Date
    
    static var mock: Tournament {
        .init(id: UUID(), name: "UEFA EURO 2024", from: .now, to: .distantFuture)
    }
}
