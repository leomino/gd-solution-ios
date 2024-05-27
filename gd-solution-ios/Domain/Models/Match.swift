//
//  Models.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import Foundation

struct Match: Identifiable, Codable, Equatable {
    public let id: UUID
    public let homeTeam: Team
    public let awayTeam: Team
    public let homeTeamScore: Int?
    public let awayTeamScore: Int?
    public let winnerTeam: Team?
    public var prediction: Prediction?
    public let startAt: Date
        
    var startAtFormatted: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day], from: .now, to: startAt)

        if let days = components.day, days > 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, HH:mm"
            return formatter.string(from: startAt)
        } else if let days = components.day, days > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EE, HH:mm"
            return formatter.string(from: startAt)
        } else if let hours = components.hour, hours > 0 {
            return "In \(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "In \(minutes)min"
        } else if let minutes = components.minute, minutes > -90 {
            return "Läuft gerade eben"
        } else {
            return "Bereits gelaufen"
        }
    }
    
    static var mock: Match {
        .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: nil, awayTeamScore: nil, winnerTeam: nil, prediction: .mock, startAt: .distantPast)
    }
    
    static var mockPlayingNextWeek: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: nil, prediction: .mock, startAt: .init(timeIntervalSinceNow: 691_200))
    }
    
    static var mockPlayingThisWeek: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: nil, prediction: .mock, startAt: .init(timeIntervalSinceNow: 86_400))
    }
    
    static var mockPlayingToday: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: nil, prediction: .mock, startAt: .init(timeIntervalSinceNow: 28_800))
    }
    
    static var mockPlayingInMinutes: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: nil, prediction: .mock, startAt: .init(timeIntervalSinceNow: 900))
    }
    
    static var mockCurrentlyPlaying: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: nil, prediction: .mock, startAt: .init(timeIntervalSinceNow: -900))
    }
    
    static var mockOver: Match {
        return .init(id: UUID(), homeTeam: .mock, awayTeam: .mock, homeTeamScore: 0, awayTeamScore: 1, winnerTeam: .mock, prediction: .mock, startAt: .distantPast)
    }
}

