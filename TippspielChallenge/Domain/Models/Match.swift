//
//  Models.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import Foundation

struct MatchResult: Codable, Equatable {
    var matchId: Match.ID
    var homeTeamScore: Int
    var awayTeamScore: Int
    var finalized: Bool
    
    static var mock: MatchResult {
        .init(matchId: UUID(), homeTeamScore: 0, awayTeamScore: 0, finalized: false)
    }
    
    static var mockNotFinalized: MatchResult {
        .init(matchId: UUID(), homeTeamScore: 1, awayTeamScore: 2, finalized: false)
    }
    
    static var mockFinalized: MatchResult {
        .init(matchId: UUID(), homeTeamScore: 1, awayTeamScore: 2, finalized: true)
    }
}

struct Match: Identifiable, Codable, Equatable {
    let id: UUID
    let homeTeam: Team
    let awayTeam: Team
    var result: MatchResult
    var prediction: Prediction?
    let stadium: Stadium
    let startAt: Date
    var points: Int?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.homeTeam = try container.decode(Team.self, forKey: .homeTeam)
        self.awayTeam = try container.decode(Team.self, forKey: .awayTeam)
        self.result = try container.decode(MatchResult.self, forKey: .result)
        self.prediction = try container.decodeIfPresent(Prediction.self, forKey: .prediction)
        self.stadium = try container.decode(Stadium.self, forKey: .stadium)
        self.startAt = try container.decode(Date.self, forKey: .startAt)
        
        calculatePoints()
    }
    
    init(id: UUID, homeTeam: Team, awayTeam: Team, result: MatchResult, prediction: Prediction? = nil, stadium: Stadium, startAt: Date, points: Int? = nil) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.result = result
        self.prediction = prediction
        self.stadium = stadium
        self.startAt = startAt
        self.points = points
        
        calculatePoints()
    }
    
    mutating func calculatePoints() {
        guard hasStarted else {
            points = nil
            return
        }
        
        guard let prediction else {
            points = 0
            return
        }
        
        let homeTeamScore = result.homeTeamScore
        let awayTeamScore = result.awayTeamScore
        
        // exact prediction
        if prediction.homeTeamScore == homeTeamScore && prediction.awayTeamScore == awayTeamScore {
            points = 8
            return
        }

        // correct goal difference
        if prediction.homeTeamScore - prediction.awayTeamScore == homeTeamScore - awayTeamScore
            && homeTeamScore != awayTeamScore {
            points = 6
            return
        }

        let tendency = (prediction.homeTeamScore - prediction.awayTeamScore).signum()
        let actualTendency = (homeTeamScore - awayTeamScore).signum()

        // correct tendency
        if tendency == actualTendency {
            points = 4
            return
        }
        
        points = 0
    }
    
    var hasStarted: Bool {
        startAt.timeIntervalSinceNow < 0
    }
    
    var currentlyPlaing: Bool {
        hasStarted && !result.finalized
    }
    
    var alreadyOver: Bool {
        hasStarted && result.finalized
    }
    
    var startAtFormatted: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: .now, to: startAt)

        if let days = components.day, days < 0 || alreadyOver {
            return "Bereits gelaufen"
        }
        
        if let days = components.day, days > 5 {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, HH:mm"
            return formatter.string(from: startAt)
        } else if let days = components.day, days == 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Morgen, um \(formatter.string(from: startAt))"
        } else if let days = components.day, days > 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EE, HH:mm"
            return formatter.string(from: startAt)
        } else if let hours = components.hour, hours > 0 {
            return "In \(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "In \(minutes)min"
        } else {
            return "Läuft gerade eben"
        }
    }
    
    static var mock: Match {
        mockPlayingNextWeek
    }
    
    static var mockPlayingNextWeek: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mock, prediction: .mock, stadium: .mock, startAt: .init(timeIntervalSinceNow: 691_200))
    }
    
    static var mockPlayingThisWeek: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mock, prediction: .mock, stadium: .mock, startAt: .init(timeIntervalSinceNow: 259_200))
    }
    
    static var mockPlayingToday: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mock, prediction: .mock, stadium: .mock, startAt: .init(timeIntervalSinceNow: 36_000))
    }
    
    static var mockPlayingInMinutes: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mock, prediction: .mock, stadium: .mock, startAt: .init(timeIntervalSinceNow: 900))
    }
    
    static var mockCurrentlyPlaying: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mockNotFinalized, prediction: .mock, stadium: .mock, startAt: .init(timeIntervalSinceNow: -900))
    }
    
    static var mockOver: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, result: .mockFinalized, prediction: .mock, stadium: .mock, startAt: .distantPast)
    }
}
