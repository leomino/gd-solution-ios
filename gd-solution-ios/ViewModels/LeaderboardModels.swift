//
//  Leaderboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import SwiftUI

class LeaderboardModel: LoadingStateModel<Leaderboard> {
    let dataService: LeaderboardDataServiceProtocol
    init(dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<Leaderboard>, dataService: LeaderboardDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchPreview(for communityId: Community.ID) {
        requests.send(dataService.fetchPreview(for: communityId))
    }
}

class LeaderboardsModel: LoadingStateModel<[Leaderboard]> {
    let dataService: LeaderboardDataServiceProtocol
    init(dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<[Leaderboard]>, dataService: LeaderboardDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchAll() {
        requests.send(dataService.fetchAll())
    }
    
    func fetchPreviews() {
        requests.send(dataService.fetchPreviews())
    }
}

class LeaderboardPaginationModel: LoadingStateModelNE<([LeaderboardEntry], LeaderboardPaginationModel.RequestType, Int)> {
    enum RequestType {
        case previous, next
    }
    
    let dataService: LeaderboardDataServiceProtocol
    let leaderboard: Leaderboard
    @Published var chunks: [[LeaderboardEntry]]
    
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
        self.chunks = initialChunks
        
        super.init(state: .idle)
        
        self.$state.sink { [weak self] state in
            guard let self else { return }
            switch state {
            case .success(let (entries, type, at)):
                switch type {
                case .next:
                    self.chunks[at] += entries
                    if self.chunks[at].last!.position == self.chunks[at + 1].first!.position - 1 {
                        self.chunks[at] += self.chunks.remove(at: at + 1)
                    }
                case .previous:
                    self.chunks[at] = entries + self.chunks[at]
                    if self.chunks[at].first!.position == self.chunks[at - 1].last!.position + 1 {
                        self.chunks[at - 1] += self.chunks.remove(at: at)
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
