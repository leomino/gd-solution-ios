//
//  CommunityListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

struct CommunityListEntry: View {
    let community: Community
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(community.name)
                    .font(.headline)
//                Text(community.members.map(\.name).joined(separator: ", "))
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
            }
            Spacer()
//            let totalPoints = community.members.map(\.points).reduce(0, +)
//            Text("Total points: \(totalPoints)")
//                .font(.subheadline)
//                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    List {
        CommunityListEntry(community: .mock)
    }
}
