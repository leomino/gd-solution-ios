//
//  LeaderBoardListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderBoardListEntry: View {
    let member: User
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(index + 1).")
                .font(.title2)
                .foregroundStyle(index == 0 ? .yellow : index == 1 ? .gray : index == 2 ? .brown : .primary)
            
            VStack(alignment: .leading) {
                Text(member.name)
                    .font(.headline)
                Text("Points: \(member.points)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        LeaderBoardListEntry(member: .mock, index: 0)
    }
}
