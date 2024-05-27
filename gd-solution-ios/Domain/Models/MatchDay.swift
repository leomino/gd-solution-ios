//
//  MatchDay.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import Foundation

struct MatchDay: Identifiable, Codable, Equatable {
    public let id: UUID
    public let from: Date
    public let to: Date
    public var matches: [Match]
    
    var dateRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        
        return "\(formatter.string(from: from)) - \(to.formatted(date: .abbreviated, time: .omitted))"
    }
    
    static var mock: MatchDay {
        .init(id: UUID(), from: .distantPast, to: .distantFuture, matches: [.mockCurrentlyPlaying, .mockPlayingInMinutes, .mockPlayingToday, .mockPlayingThisWeek, .mockPlayingNextWeek])
    }
}
