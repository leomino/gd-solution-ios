//
//  TournamentDashboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 24.05.24.
//

import SwiftUI

struct TournamentDashboard: View {
    let tournament: Tournament
    @ObservedObject var matchViewModel: MatchesViewModel
    @ObservedObject var leaderboardViewModel: LeaderboardModel
    @State private var selectedMatch: Match? = nil
    
    init(
        tournament: Tournament,
        matchDataService: MatchDataServiceProtocol = MatchDataService(),
        leaderboardDataService: LeaderboardDataServiceProtocol = LeaderboardDataService()
    ) {
        self.tournament = tournament
        _matchViewModel = ObservedObject(wrappedValue: .init(dataService: matchDataService))
        _leaderboardViewModel = ObservedObject(wrappedValue: .init(dataService: leaderboardDataService))
    }
    
    init(
        tournament: Tournament,
        matchesViewModel: MatchesViewModel,
        leaderboardViewModel: LeaderboardModel
    ) {
        self.tournament = tournament
        _matchViewModel = ObservedObject(wrappedValue: matchesViewModel)
        _leaderboardViewModel = ObservedObject(wrappedValue: leaderboardViewModel)
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
                        MatchListEntry(match: match)
                            .onTapGesture {
                                selectedMatch = match
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
                switch leaderboardViewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                case .success(let leaderboards):
                    ForEach(leaderboards) { leaderboard in
                        NavigationLink {
                            LeaderboardView(leaderboard: leaderboard)
                                .navigationTitle(leaderboard.community.name)
                        } label: {
                            LeaderboardPreview(leaderboard: leaderboard)
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
        .onAppear {
            if case .idle = matchViewModel.state {
                matchViewModel.fetchNextMatches()
            }
            if case .idle = leaderboardViewModel.state {
                leaderboardViewModel.fetchPreviews()
            }
        }
        .refreshable {
            leaderboardViewModel.fetchPreviews()
            matchViewModel.fetchNextMatches()
        }
        .sheet(item: $selectedMatch) { match in
            NavigationStack {
                PredictionView(match: match, onUpsert: { matchId, prediction in
                    matchViewModel.upsertPredictionInStore(for: matchId, with: prediction)
                })
                .navigationTitle(match.prediction != nil ? "Wette bearbeiten" : "Wette abgeben")
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview("Success") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            matchDataService: MatchDataServiceMock(),
            leaderboardDataService: LeaderboardDataServiceMock()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            matchesViewModel: .init(state: .loading, dataService: MatchDataServiceMock()),
            leaderboardViewModel: .init(state: .loading, dataService: LeaderboardDataServiceMock())
        )
    }
}

#Preview("Error") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            matchesViewModel: .init(state: .failure(NSError.notFound), dataService: MatchDataServiceMock()),
            leaderboardViewModel: .init(state: .failure(NSError.notFound), dataService: LeaderboardDataServiceMock())
        )
    }
}
