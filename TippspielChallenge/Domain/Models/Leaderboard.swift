//
//  Leaderboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import Foundation

struct Leaderboard: Identifiable, Codable, Equatable {
    var id: UUID {
        communityId
    }
    let communityId: UUID
    var chunks: [[LeaderboardEntry]]
    var community: Community?
    
    static var mock: Leaderboard {
        .init(communityId: UUID(), chunks: [[.mock(position: 1), .mock(position: 2), .mock(position: 3)], [.mock(position: 8)], [.mock(position: 15)]])
    }
}

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    var id: String {
        username
    }
    var username: String
    var position: Int
    var score: Int
    var user: User?
    
    static func mock(position: Int) -> Self {
        .init(username: "leokeo123", position: position, score: 120)
    }
}
