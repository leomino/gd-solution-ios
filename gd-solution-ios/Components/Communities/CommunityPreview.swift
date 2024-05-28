//
//  CommunityPreview.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct CommunityPreview: View {
    let community: Community
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(community.name)
                    .font(.headline)
                Spacer()
                Text("Punkte")
                    .font(.subheadline)
            }
            ForEach(Array(community.members.sorted(by: { $0.points < $1.points }).enumerated()), id: \.offset) { position, member in
                HStack {
                    LeaderBoardListEntry(member: member, position: position)
                    Spacer()
                    Text(String(member.points))
                }
            }
            .listRowSeparator(.hidden)
            
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CommunityPreview(community: .mock)
        }
    }
}
