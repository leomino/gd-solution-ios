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
    
    static var mock: User {
        .init(username: "leokeo123", name: "Leonardo", supports: .mock, points: 120)
    }
}
