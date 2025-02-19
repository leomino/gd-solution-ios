//
//  Community.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import Foundation

class CommunityModel: LoadingStateModel<Community> {
    let dataService: CommunityDataServiceProtocol
    
    init(state: LoadingState<Community> = .idle, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func createCommunity(_ community: Community) {
        requests.send(dataService.create(community))
    }
    
    func joinCommunity(communityId: Community.ID) {
        requests.send(dataService.join(communityId: communityId))
    }
    
    func fetchCommunity(communityId: Community.ID) {
        requests.send(dataService.fetchById(communityId: communityId))
    }
}

class CommunitiesModel: LoadingStateModel<[Community]> {
    let dataService: CommunityDataServiceProtocol
    
    init(state: LoadingState<[Community]> = .idle, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchCommunities() {
        requests.send(dataService.fetchAll())
    }
    
    func insertCommunityInStore(community: Community) {
        if case .success(var communities) = self.state {
            communities.append(community)
            self.state = .success(communities)
        }
    }
}

class CommunitySuggestionModel: LoadingStateModel<[Community]> {
    let dataService: CommunityDataServiceProtocol
    @Published var searchString = ""
    
    init(state: LoadingState<[Community]> = .idle, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(state: state)
        
        $searchString.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchString in
                guard !searchString.isEmpty else {
                    return
                }
                self?.requests.send(dataService.searchBy(searchString: searchString))
            }
            .store(in: &cancellables)
    }
}
