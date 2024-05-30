//
//  CommunityPreview.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderboardPreview: View {
    let leaderboard: Leaderboard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(leaderboard.community.name)
                    .font(.headline)
                Spacer()
                Text("Punkte")
                    .font(.subheadline)
            }
            ForEach(leaderboard.entries) { entry in
                LeaderBoardListEntry(member: entry.user, position: entry.position)
            }
        }
    }
}

#Preview {
    LeaderboardPreview(leaderboard: .mock)
        .padding()
}
