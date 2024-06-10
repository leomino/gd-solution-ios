//
//  Models.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import Foundation

public struct Match: Identifiable {
    public let id: String
    public let matchDay: MatchDay
    public let homeTeam: Team
    public let awayTeam: Team
    public let homeTeamScore: Int?
    public let awayTeamScore: Int?
    public let startAt: Date
    
    public init(id: String, matchDay: MatchDay, homeTeam: Team, awayTeam: Team, homeTeamScore: Int? = nil, awayTeamScore: Int? = nil, startAt: Date) {
        self.id = id
        self.matchDay = matchDay
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.startAt = startAt
    }
    
    static var mock: Match {
        Self.init(id: "match_id", matchDay: .mock, homeTeam: .mock, awayTeam: .mock, startAt: .distantFuture)
    }
}

