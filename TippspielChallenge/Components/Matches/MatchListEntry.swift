//
//  MatchListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct MatchListEntry: View {
    var match: Match
    var showPoints = true
    
    var prediction: String {
        if let prediction = match.prediction {
            return "Gewettet \(prediction.homeTeamScore) zu \(prediction.awayTeamScore)"
        }
        return match.hasStarted ? "Keine Wette abgegeben" : "Noch nicht gewettet"
    }
    
    var standing: String {
        return "\(match.result.homeTeamScore) zu \(match.result.awayTeamScore)"
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
            VStack(alignment: .leading, spacing: showPoints ? 4 : 16) {
                Text(match.startAtFormatted)
                    .foregroundStyle(match.currentlyPlaing ? .red : .primary)
                    .font(.headline)
                if showPoints {
                    HStack {
                        Text(prediction)
                            .font(.subheadline)
                        Spacer()
                        if match.prediction == nil && !match.hasStarted {
                            Circle()
                                .fill(.blue)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                Text("\(match.homeTeam.name) vs. \(match.awayTeam.name)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if !showPoints {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            if match.hasStarted || match.result.finalized || match.result.awayTeamScore > 0 || match.result.homeTeamScore > 0 {
                HStack {
                    Text(standing)
                        .padding(2)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(match.currentlyPlaing ? .red.opacity(0.15) : .blue.opacity(0.15))
                        }
                        .foregroundStyle(match.currentlyPlaing ? .red : .blue)
                    if let points = match.points, showPoints {
                        Text("+\(points)P")
                    }
                }
                .font(.footnote)
            }
        }
    }
}

#Preview("Playing next week") {
    MatchListEntry(match: .mockPlayingNextWeek)
        .padding()
}

#Preview("Playing this week") {
    MatchListEntry(match: .mockPlayingThisWeek)
        .padding()
}

#Preview("Playing today") {
    MatchListEntry(match: .mockPlayingToday)
        .padding()
}

#Preview("Playing in minutes") {
    MatchListEntry(match: .mockPlayingInMinutes)
        .padding()
}

#Preview("Currently playing") {
    MatchListEntry(match: .mockCurrentlyPlaying)
        .padding()
}

#Preview("Already over") {
    MatchListEntry(match: .mockOver)
        .padding()
}
