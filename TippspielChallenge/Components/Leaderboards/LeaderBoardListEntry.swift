//
//  LeaderBoardListEntry.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

struct LeaderBoardListEntry: View {
    private let currentUsername = UserDefaults.standard.string(forKey: AuthenticationModel.USERNAME)
    let username: String
    let position: Int
    let score: Int
    let user: User?
    
    init(leaderboardEntry: LeaderboardEntry) {
        username = leaderboardEntry.username
        position = leaderboardEntry.position
        score = leaderboardEntry.score
        user = leaderboardEntry.user
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(position).")
            
            if let supports = user?.supports {
                Circle()
                    .frame(width: 20)
                    .overlay {
                        Image(supports.nameShort)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(Circle())
            }
            
            HStack {
                if let name = user?.name {
                    Text(currentUsername == username ? "Du" : name)
                        .font(.headline)
                }
                Text("@\(username)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(score))
            }
            .fontWeight(.regular)
        }
    }
}

//#Preview {
//    List {
//        LeaderBoardListEntry(member: .mock, position: 1)
//        LeaderBoardListEntry(member: .mock, position: 2)
//        LeaderBoardListEntry(member: .mock, position: 3)
//        LeaderBoardListEntry(member: .mock, position: 4)
//    }
//}
