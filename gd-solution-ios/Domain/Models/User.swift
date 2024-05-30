//
//  User.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    var id: String {
        username
    }
    let username: String
    let name: String
    let supports: Team?
    let points: Int
    let joinedAt: Date
    
    init(username: String, name: String, supports: Team? = nil, points: Int = 0, joinedAt: Date = .now) {
        self.username = username
        self.name = name
        self.supports = supports
        self.points = points
        self.joinedAt = joinedAt
    }
    
    static var mock: User {
        .init(username: UUID().uuidString.prefix(6).lowercased(), name: UUID().uuidString.prefix(6).capitalized, supports: .mock, points: 120, joinedAt: .now)
    }
}
