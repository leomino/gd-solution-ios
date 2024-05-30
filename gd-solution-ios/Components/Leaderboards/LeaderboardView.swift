//
//  LeaderboardView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var paginationModel: LeaderboardPaginationModel
    @ObservedObject private var suggestionModel: LeaderboardSuggestionModel
    
    init(leaderboard: Leaderboard, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        _paginationModel = ObservedObject(wrappedValue: .init(leaderboard: leaderboard, dataService: dataService))
        _suggestionModel = ObservedObject(wrappedValue: .init(community: leaderboard.community, dataService: dataService))
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
                                let limit = min(first.position - offset - 1, 10)
                                paginationModel.fetchEntries(offset: offset, limit: limit, type: .previous, at: index)
                            } label: {
                                Image(systemName: "chevron.up")
                            }
                            .buttonStyle(.bordered)
                        }
                        ForEach(Array(entries.enumerated()), id: \.offset) { offset, entry in
                            if offset >= 1 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.secondary.opacity(0.2))
                                    .frame(height: 1)
                            }
                            
                            LeaderBoardListEntry(member: entry.user, position: entry.position)
                        }
                        if index < chunks.count - 1 {
                            Button {
                                guard let last = entries.last, let nextFirst = chunks[index + 1].first else {
                                    return
                                }
                                let offset = last.position
                                let limit = min(nextFirst.position - offset - 1, 10)
                                paginationModel.fetchEntries(offset: offset, limit: limit, type: .next, at: index)
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()
            } else {
                switch suggestionModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .success(let entries):
                    VStack(spacing: 16) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { offset, entry in
                            if offset >= 1 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.secondary.opacity(0.2))
                                    .frame(height: 1)
                            }
                            LeaderBoardListEntry(member: entry.user, position: entry.position)
                        }
                    }
                    .padding()
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                }
            }
        }
        .searchable(text: $suggestionModel.usernameFilter)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView(leaderboard: .mock)
            .padding()
    }
}
