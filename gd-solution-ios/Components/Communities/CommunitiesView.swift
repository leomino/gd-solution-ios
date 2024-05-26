//
//  CommunitiesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

class CommunitiesViewModel: LoadingStateModel<[Community]> {
    let dataService: CommunityDataServiceProtocol
    init(dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(publisher: dataService.fetchAll())
    }
    
    init(state: LoadingState<[Community]>, dataService: CommunityDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchCommunities() {
        requests.send(dataService.fetchAll())
    }
}

struct CommunitiesView: View {
    let tournament: Tournament
    @ObservedObject var viewModel: CommunitiesViewModel
    
    init(tournament: Tournament, dataService: CommunityDataService = CommunityDataService()) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: CommunitiesViewModel(dataService: dataService))
    }
    
    init(tournament: Tournament, state: LoadingState<[Community]>, dataService: CommunityDataServiceProtocol) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Text("Nach unten ziehen um Gemeinschaften zu laden.")
            case .loading:
                ProgressView()
            case .success(let communities):
                List(communities) { community in
                    NavigationLink {
                        LeaderBoardView(community: community)
                    } label: {
                        CommunityListEntry(community: community)
                    }
                }
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(tournament.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {}
            }
        }
    }
}

#Preview("Success") {
    NavigationStack {
        CommunitiesView(tournament: .mock)
    }
}

#Preview("Loading") {
    NavigationStack {
        CommunitiesView(tournament: .mock, state: .loading, dataService: CommunityDataServiceMock())
    }
}

#Preview("Failure") {
    NavigationStack {
        CommunitiesView(tournament: .mock, state: .failure(NSError.notFound), dataService: CommunityDataServiceMock())
    }
}
