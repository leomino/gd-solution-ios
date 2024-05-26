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
                Spacer()
                Text("Punkte")
            }
            .font(.headline)
            ForEach(Array(community.members.sorted(by: { $0.points < $1.points }).enumerated()), id: \.offset) { position, member in
                HStack(spacing: 4) {
                    Text("\(position + 1).")
                        .font(.title2)
                        .foregroundStyle(position == 0 ? .yellow : position == 1 ? .gray : position == 2 ? .brown : .primary)
                    Text(member.name)
                    Spacer()
                    Text("\(member.points)")
                }
                .font(.subheadline)
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
