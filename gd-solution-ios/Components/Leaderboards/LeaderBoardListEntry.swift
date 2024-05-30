//
//  LeaderBoardListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderBoardListEntry: View {
    private let currentUsername: String
    let member: User
    let position: Int
    
    init(member: User, position: Int) {
        self.currentUsername = UserDefaults.standard.string(forKey: AuthenticationModel.USERNAME) ?? ""
        self.member = member
        self.position = position
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(position).")
                .font(.title2)
                .foregroundStyle(position == 1 ? .yellow : position == 2 ? .gray : position == 3 ? .brown : .primary)
            
//            if let supports = member.supports {
//                Circle()
//                    .frame(width: 20)
//                    .overlay {
//                        Image(supports.nameShort)
//                            .resizable()
//                            .scaledToFill()
//                    }
//                    .clipShape(Circle())
//            }
            
            HStack {
                Text(currentUsername == member.username ? "Du" : member.name)
                    .font(.headline)
                Text("@\(member.username)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(member.points))
            }
            .fontWeight(member.username == currentUsername ? .bold : .medium)
        }
    }
}

#Preview {
    List {
        LeaderBoardListEntry(member: .mock, position: 1)
        LeaderBoardListEntry(member: .mock, position: 2)
        LeaderBoardListEntry(member: .mock, position: 3)
        LeaderBoardListEntry(member: .mock, position: 4)
    }
}
