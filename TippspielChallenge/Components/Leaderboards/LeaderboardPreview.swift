//
//  CommunityPreview.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderboardPreview: View {
    @State private var leaderboard: Leaderboard
    @ObservedObject private var communityModel: CommunityModel
    
    init(leaderboard: Leaderboard, communityModel: CommunityModel = .init()) {
        self.leaderboard = leaderboard
        self.communityModel = communityModel
    }
    
    var body: some View {
        NavigationLink {
            LeaderboardView(leaderboard: leaderboard)
                .navigationTitle(leaderboard.community != nil ? leaderboard.community!.name : leaderboard.communityId.uuidString)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Group {
                        if let community = leaderboard.community {
                            Text(community.name)
                        } else {
                            Text("...")
                        }
                    }
                    .font(.headline)
                    
                    Spacer()
                    
                    Text("Punkte")
                        .font(.subheadline)
                }
                ForEach(leaderboard.chunks.flatMap { $0 }) { entry in
                    LeaderBoardListEntry(leaderboardEntry: entry)
                        .font(.body)
                        .fontWeight(.regular)
                }
            }
        }
        .onChange(of: communityModel.state) {
            if case .success(let community) = communityModel.state {
                leaderboard.community = community
            }
        }
        .onAppear {
            if case .idle = communityModel.state {
                communityModel.fetchCommunity(communityId: leaderboard.communityId)
            }
        }
    }
}

#Preview("Community success") {
    LeaderboardPreview(leaderboard: .mock)
        .padding()
}

#Preview("Community loading") {
    LeaderboardPreview(leaderboard: .mock)
        .padding()
}
