//
//  MatchListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct MatchListEntry: View {
    var match: Match
    
    var prediction: String {
        if let prediction = match.prediction {
            return "Gewettet \(prediction.homeTeamScore) zu \(prediction.awayTeamScore)"
        }
        return "Noch nicht gewettet"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .frame(width: 35)
                    .overlay {
                        Image(match.homeTeam.nameShort)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(Circle())
                
                Circle()
                    .frame(width: 35)
                    .overlay {
                        Image(match.awayTeam.nameShort)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(match.startAtFormatted)
                    .font(.headline)
                HStack {
                    Text(prediction)
                        .font(.subheadline)
                    Spacer()
                    if match.prediction == nil {
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                    }
                }
                Text("\(match.homeTeam.name) vs. \(match.awayTeam.name)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview("Over") {
    List {
        MatchListEntry(match: .mockPlayingNextWeek)
        MatchListEntry(match: .mockPlayingThisWeek)
        MatchListEntry(match: .mockPlayingToday)
        MatchListEntry(match: .mockPlayingInMinutes)
        MatchListEntry(match: .mockCurrentlyPlaying)
        MatchListEntry(match: .mockOver)
    }
}
