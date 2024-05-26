//
//  Bet.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import Foundation

struct Prediction: Identifiable, Codable, Equatable {
    var id: String {
        username + matchId.uuidString
    }
    let username: String
    let matchId: UUID
    let homeTeamScore: Int
    let awayTeamScore: Int
    
    static var mock: Prediction {
        .init(username: "leokeo123", matchId: UUID(), homeTeamScore: 0, awayTeamScore: 2)
    }
}
