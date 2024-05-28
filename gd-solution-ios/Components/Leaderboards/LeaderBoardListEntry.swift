//
//  LeaderBoardListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderBoardListEntry: View {
    let member: User
    let position: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(position + 1).")
                .font(.title2)
                .foregroundStyle(position == 0 ? .yellow : position == 1 ? .gray : position == 2 ? .brown : .primary)
            
            if let supports = member.supports {
                Circle()
                    .frame(width: 20)
                    .overlay {
                        Image(supports.nameShort)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                    Text("@\(member.username)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("Points: \(member.points)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        LeaderBoardListEntry(member: .mock, position: 0)
    }
}
