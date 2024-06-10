//
//  Leaderboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import Combine
import SwiftUI

class LeaderboardModel: LoadingStateModel<Leaderboard> {
    let dataService: LeaderboardDataServiceProtocol
    
    init(state: LoadingState<Leaderboard> = .idle, dataService: LeaderboardDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchPreview(for communityId: Community.ID) {
        requests.send(dataService.fetchBy(communityId))
    }
}

class LeaderboardsModel: LoadingStateModel<[Leaderboard]> {
    let dataService: LeaderboardDataServiceProtocol
        
    init(state: LoadingState<[Leaderboard]> = .idle, dataService: LeaderboardDataServiceProtocol = LeaderboardDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchPreviews() {
        requests.send(dataService.fetchAll())
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
        self.chunks = leaderboard.chunks
        
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
        requests.send(dataService.fetchPagination(in: leaderboard.id, offset: offset, limit: limit, type: type, at: at))
    }
}

class LeaderboardSuggestionModel: LoadingStateModel<[LeaderboardEntry]> {
    let communityId: Community.ID
    let dataService: LeaderboardDataServiceProtocol
    @Published var usernameFilter = ""
    
    init(communityId: Community.ID, dataService: LeaderboardDataServiceProtocol) {
        self.dataService = dataService
        self.communityId = communityId
        super.init(state: .idle)
        
        $usernameFilter.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchString in
                guard !searchString.isEmpty else {
                    return
                }
                self?.requests.send(dataService.searchEntries(in: communityId, with: searchString))
            }
            .store(in: &cancellables)
    }
}
