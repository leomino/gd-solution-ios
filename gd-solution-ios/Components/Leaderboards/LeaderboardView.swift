//
//  LeaderboardView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import SwiftUI

class LeaderboardEntryViewModel: LoadingStateModelNE<([LeaderboardEntry], LeaderboardEntryViewModel.RequestType, Int)> {
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
        requests.send(dataService.fetchLeaderboardEntries(for: leaderboard.community.id, offset: offset, limit: limit, type: type, at: at))
    }
}

struct LeaderboardView: View {
    let currentUsername = "leokeo123"
    @ObservedObject private var viewModel: LeaderboardEntryViewModel
    
    init(leaderboard: Leaderboard, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        _viewModel = ObservedObject(wrappedValue: .init(leaderboard: leaderboard, dataService: dataService))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(viewModel.splittedEntries.enumerated()), id: \.offset) { index, entries in
                    if index >= 1 {
                        Button {
                            let offset = max(entries.first!.position - 11, viewModel.splittedEntries[index - 1].last!.position)
                            let limit = min(entries.first!.position - offset - 1, 10)
                            viewModel.fetchEntries(offset: offset, limit: limit, type: .previous, at: index)
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
                    if index < viewModel.splittedEntries.count - 1 {
                        Button {
                            let offset = entries.last!.position
                            let limit = min(viewModel.splittedEntries[index + 1].first!.position - offset - 1, 10)
                            viewModel.fetchEntries(offset: offset, limit: limit, type: .next, at: index)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        LeaderboardView(leaderboard: .mock)
            .padding()
    }
}
