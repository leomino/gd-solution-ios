//
//  Leaderboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import Foundation

struct Leaderboard: Identifiable, Codable, Equatable {
    let id = UUID()
    let community: Community
    var entries: [LeaderboardEntry]
    
    private enum CodingKeys: String, CodingKey {
        case community, entries
    }
    
    static var mock: Leaderboard {
        .init(community: .mock, entries: [.mock(position: 1), .mock(position: 2), .mock(position: 3), .mock(position: 8), .mock(position: 15)])
    }
}

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    var id: User.ID {
        user.id
    }
    let user: User
    var position: Int
    
    static func mock(position: Int) -> Self {
        .init(user: .mock, position: position)
    }
}

