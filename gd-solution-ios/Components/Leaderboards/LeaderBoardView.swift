//
//  LeaderBoardView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderBoardView: View {
    let community: Community
    
    var body: some View {
        List(Array(community.members.sorted(by: { $0.points < $1.points }).enumerated()), id: \.offset) { index, member in
            LeaderBoardListEntry(member: member, index: index)
        }
        .navigationTitle(community.name)
    }
}

#Preview {
    NavigationStack {
        LeaderBoardView(community: .mock)
    }
}
