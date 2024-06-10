//
//  LeaderboardView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import SwiftUI

struct LeaderboardLoadingView: View {
    @ObservedObject private var leaderboardModel: LeaderboardModel
    
    init(leaderboard: Leaderboard, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        leaderboardModel = .init(state: .success(leaderboard), dataService: dataService)
    }
    
    init(communityId: UUID, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        self.leaderboardModel = .init(state: .idle, dataService: dataService)
        leaderboardModel.fetchPreview(for: communityId)
    }
    
    var body: some View {
        Group {
            switch leaderboardModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .success(let leaderboard):
                LeaderboardView(leaderboard: leaderboard)
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
        }
    }
}

struct LeaderboardView: View {
    let currentUsername = UserDefaults.standard.string(forKey: AuthenticationModel.USERNAME)
    @ObservedObject private var paginationModel: LeaderboardPaginationModel
    @ObservedObject private var suggestionModel: LeaderboardSuggestionModel
    
    init(
        leaderboard: Leaderboard,
        dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()
    ) {
        self.paginationModel = .init(leaderboard: leaderboard, dataService: dataService)
        self.suggestionModel = .init(communityId: leaderboard.communityId, dataService: dataService)
    }
    
    var body: some View {
        ScrollView {
            if suggestionModel.usernameFilter.isEmpty {
                VStack(spacing: 16) {
                    let chunks = paginationModel.chunks
                    ForEach(Array(chunks.enumerated()), id: \.offset) { index, entries in
                        if index >= 1 {
                            Button {
                                guard let first = entries.first, let previousLast = chunks[index - 1].last else {
                                    return
                                }
                                let offset = max(first.position - 11, previousLast.position)
                                let limit = min(first.position - offset - 1, 10) + offset - 1
                                paginationModel.fetchEntries(offset: offset, limit: limit, type: .previous, at: index)
                            } label: {
                                Image(systemName: "chevron.up")
                            }
                            .buttonStyle(.bordered)
                        }
                        VStack(spacing: 0) {
                            ForEach(Array(entries.enumerated()), id: \.offset) { offset, entry in
                                if offset >= 1 {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.secondary.opacity(0.2))
                                        .frame(height: 1)
                                }
                                
                                LeaderBoardListEntry(leaderboardEntry: entry)
                                    .padding()
                                    .background {
                                        if currentUsername == entry.username {
                                            Rectangle().fill(.blue.opacity(0.15))
                                        }
                                    }
                            }
                        }
                        if index < chunks.count - 1 {
                            Button {
                                guard let last = entries.last, let nextFirst = chunks[index + 1].first else {
                                    return
                                }
                                let offset = last.position
                                let limit = min(nextFirst.position - offset - 1, 10) + offset - 1
                                paginationModel.fetchEntries(offset: offset, limit: limit, type: .next, at: index)
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            } else {
                switch suggestionModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .success(let entries):
                    VStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { offset, entry in
                            if offset >= 1 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.secondary.opacity(0.2))
                                    .frame(height: 1)
                            }
                            LeaderBoardListEntry(leaderboardEntry: entry)
                                .padding()
                                .background {
                                    if currentUsername == entry.username {
                                        Rectangle().fill(.blue.opacity(0.15))
                                    }
                                }
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .padding()
                }
            }
        }
        .searchable(text: $suggestionModel.usernameFilter)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView(leaderboard: .mock)
    }
}
