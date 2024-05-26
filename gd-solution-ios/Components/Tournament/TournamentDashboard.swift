//
//  TournamentDashboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 24.05.24.
//

import SwiftUI

class MatchesViewModel: LoadingStateModel<[Match]> {
    let dataService: MatchDataServiceProtocol
    init(dataService: MatchDataServiceProtocol = MatchDataService()) {
        self.dataService = dataService
        super.init(publisher: dataService.fetchNext())
    }
    
    init(state: LoadingState<[Match]>, dataService: MatchDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchAllMatches() {
        requests.send(dataService.fetchAll())
    }
    
    func fetchNextMatches() {
        requests.send(dataService.fetchNext())
    }
}

struct TournamentDashboard: View {
    let tournament: Tournament
    @ObservedObject var matchViewModel = MatchesViewModel()
    @ObservedObject var communityViewModel = CommunitiesViewModel()
    
    init(
        tournament: Tournament,
        communityDataService: CommunityDataServiceProtocol = CommunityDataService(),
        matchDataService: MatchDataServiceProtocol = MatchDataService()
    ) {
        self.tournament = tournament
        _communityViewModel = ObservedObject(wrappedValue: CommunitiesViewModel(dataService: communityDataService))
        _matchViewModel = ObservedObject(wrappedValue: MatchesViewModel(dataService: matchDataService))
    }
    
    init(
        tournament: Tournament,
        communitiesViewModel: CommunitiesViewModel,
        matchesViewModel: MatchesViewModel
    ) {
        self.tournament = tournament
        _communityViewModel = ObservedObject(wrappedValue: communitiesViewModel)
        _matchViewModel = ObservedObject(wrappedValue: matchesViewModel)
    }
    
    var body: some View {
        List {
            Section {
                switch matchViewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .success(let matches):
                    ForEach(matches) { match in
                        NavigationLink {
                            PredictionView(match: match)
                        } label: {
                            MatchListEntry(match: match)
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                }
            } header: {
                HStack {
                    Text("Nächste Spiele")
                    Spacer()
                    NavigationLink {
                        MatchesView()
                    } label: {
                        Text("Alle anzeigen")
                    }
                }
            }
            .headerProminence(.increased)
            Section {
                switch communityViewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .success(let communities):
                    ForEach(communities) { community in
                        NavigationLink {
                            LeaderBoardView(community: community)
                        } label: {
                            CommunityPreview(community: community)
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                }
            } header: {
                HStack {
                    Text("Gemeinschaften")
                    Spacer()
                    NavigationLink {
                        CommunitiesView(tournament: tournament)
                    } label: {
                        Text("Alle anzeigen")
                    }
                }
            }
            .headerProminence(.increased)
        }
        .navigationTitle(tournament.name)
        .refreshable {
            communityViewModel.fetchCommunities()
            matchViewModel.fetchNextMatches()
        }
    }
}

#Preview("Success") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            communityDataService: CommunityDataServiceMock(),
            matchDataService: MatchDataServiceMock()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            communitiesViewModel: .init(state: .loading, dataService: CommunityDataServiceMock()),
            matchesViewModel: .init(state: .loading, dataService: MatchDataServiceMock())
        )
    }
}

#Preview("Error") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            communitiesViewModel: .init(state: .failure(NSError.notFound), dataService: CommunityDataServiceMock()),
            matchesViewModel: .init(state: .failure(NSError.notFound), dataService: MatchDataServiceMock())
        )
    }
}
