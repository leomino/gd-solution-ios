//
//  MatchDay.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import Foundation

struct MatchDay: Identifiable, Codable, Equatable {
    let id: UUID
    let from: Date
    let to: Date
    var matches: [Match]
    var points: Int?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.from = try container.decode(Date.self, forKey: .from)
        self.to = try container.decode(Date.self, forKey: .to)
        self.matches = try container.decode([Match].self, forKey: .matches)
        
        calculatePoints()
    }
    
    init(id: UUID, from: Date, to: Date, matches: [Match], points: Int? = nil) {
        self.id = id
        self.from = from
        self.to = to
        self.matches = matches
        self.points = points
        
        calculatePoints()
    }
    
    var dateRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        return "\(formatter.string(from: from)) - \(to.formatted(date: .abbreviated, time: .omitted))"
    }
    
    mutating func calculatePoints() {
        points = matches.compactMap(\.points).reduce(0, +)
    }
    
    static var mock: MatchDay {
        .init(
            id: UUID(),
            from: .init(timeIntervalSinceNow: -604_800),
            to: .init(timeIntervalSinceNow: 604_800),
            matches: [.mockOver, .mockCurrentlyPlaying, .mockPlayingInMinutes, .mockPlayingToday, .mockPlayingThisWeek, .mockPlayingNextWeek]
        )
    }
}
