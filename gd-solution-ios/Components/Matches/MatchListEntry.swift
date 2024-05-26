//
//  MatchListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct MatchListEntry: View {
    var match: Match
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(match.homeTeam.nameShort)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45, alignment: .center)
                    .background(.secondary)
                    .clipShape(Circle())
                
                Image(match.awayTeam.nameShort)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45, alignment: .center)
                    .background(.secondary)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(match.startAtFormatted)
                    .font(.headline)
                Text("\(match.homeTeam.name) vs. \(match.awayTeam.name)")
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Gewettet: 1 zu 2")
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
