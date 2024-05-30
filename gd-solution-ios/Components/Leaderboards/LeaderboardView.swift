//
//  LeaderboardView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import SwiftUI

class LeaderboardPaginationModel: LoadingStateModelNE<([LeaderboardEntry], LeaderboardPaginationModel.RequestType, Int)> {
    enum RequestType {
        case previous, next
    }
    
    let dataService: LeaderboardDataServiceProtocol
    @Published var leaderboard: Leaderboard
    @Published var splittedEntries: [[LeaderboardEntry]]
    
    init(leaderboard: Leaderboard, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        self.leaderboard = leaderboard
        self.dataService = dataService
        
        var initialChunks = [[LeaderboardEntry]]()
        var currentChunk: [LeaderboardEntry] = []
        var expectedPosition: Int?
        for element in leaderboard.entries {
            if let expected = expectedPosition, element.position != expected {
                if !currentChunk.isEmpty {
                    initialChunks.append(currentChunk)
                }
                currentChunk = []
            }
            
            currentChunk.append(element)
            expectedPosition = element.position + 1
        }
        if !currentChunk.isEmpty {
            initialChunks.append(currentChunk)
        }
        self.splittedEntries = initialChunks
        
        super.init(state: .idle)
        
        self.$state.sink { [weak self] state in
            guard let self else { return }
            switch state {
            case .success(let (entries, type, at)):
                switch type {
                case .next:
                    self.splittedEntries[at] += entries
                    if self.splittedEntries[at].last!.position == self.splittedEntries[at + 1].first!.position - 1 {
                        self.splittedEntries[at] += self.splittedEntries.remove(at: at + 1)
                    }
                case .previous:
                    self.splittedEntries[at] = entries + self.splittedEntries[at]
                    if self.splittedEntries[at].first!.position == self.splittedEntries[at - 1].last!.position + 1 {
                        self.splittedEntries[at - 1] += self.splittedEntries.remove(at: at)
                    }
                }
            default:
                return
            }
        }
        .store(in: &cancellables)
    }
    
    func fetchEntries(offset: Int, limit: Int, type: RequestType, at: Int) {
        requests.send(dataService.fetchEntries(in: leaderboard.community.id, offset: offset, limit: limit, type: type, at: at))
    }
}

class LeaderboardSuggestionModel: LoadingStateModel<[LeaderboardEntry]> {
    let community: Community
    let dataService: LeaderboardDataServiceProtocol
    @Published var usernameFilter = ""
    
    init(community: Community, dataService: LeaderboardDataServiceProtocol) {
        self.dataService = dataService
        self.community = community
        super.init(state: .idle)
        
        $usernameFilter.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchString in
                guard !searchString.isEmpty else {
                    return
                }
                self?.requests.send(dataService.fetchEntries(in: community.id, with: searchString))
            }
            .store(in: &cancellables)
    }
}


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
                    let chunks = paginationModel.splittedEntries
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
