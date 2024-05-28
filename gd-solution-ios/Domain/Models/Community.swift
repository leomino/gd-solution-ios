//
//  Community.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Foundation

struct Community: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let tournament: Tournament
    var members: [User]
    
    static var mock: Community {
        .init(id: UUID(), name: "Freunde123", tournament: .mock, members: [.mock, .mock, .mock, .mock])
    }
}
