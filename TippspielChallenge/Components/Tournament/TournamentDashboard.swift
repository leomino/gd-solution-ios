//
//  TournamentDashboard.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 24.05.24.
//

import SwiftUI

struct TournamentDashboard: View {
    let tournament: Tournament
    let role = UserDefaults.standard.string(forKey: AuthenticationModel.ROLE)
    @ObservedObject private var matchViewModel: MatchesModel
    @ObservedObject private var leaderboardsModel: LeaderboardsModel
    @State private var selectedMatch: Match? = nil
    
    init(
        tournament: Tournament,
        matchesViewModel: MatchesModel = .init(),
        leaderboardViewModel: LeaderboardsModel = .init()
    ) {
        self.tournament = tournament
        self.matchViewModel = matchesViewModel
        self.leaderboardsModel = leaderboardViewModel
    }
    
    var body: some View {
        List {
            if let role, role == "admin" {
                NavigationLink {
                    AdminDashboard()
                        .navigationTitle("Admin Konsole")
                } label: {
                    Label("Admin", systemImage: "person.fill")
                }
            }
            
            Section {
                switch matchViewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                case .success(let matches):
                    ForEach(matches) { match in
                        MatchListEntry(match: match)
                            .onTapGesture {
                                selectedMatch = match
                            }
                    }
                case .failure(let error):
                    HStack {
                        Spacer()
                        Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .padding()
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
                switch leaderboardsModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                case .success(let leaderboards):
                    ForEach(leaderboards) { leaderboard in
                        LeaderboardPreview(leaderboard: leaderboard)
                            .padding(.bottom)
                    }
                case .failure(let error):
                    HStack {
                        Spacer()
                        Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .padding()
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
        .onAppear(perform: onAppear)
        .refreshable {
            leaderboardsModel.fetchPreviews()
            matchViewModel.fetchNextMatches()
        }
        .sheet(item: $selectedMatch) { match in
            NavigationStack {
                PredictionView(match: match, onUpsert: { matchId, prediction in
                    matchViewModel.upsertPredictionInStore(for: matchId, with: prediction)
                })
            }
        }
    }
    
    private func onAppear() {
        if case .idle = matchViewModel.state {
            matchViewModel.fetchNextMatches()
            Task {
                await matchViewModel.listenToMatchResultUpdates()
            }
        }
        if case .idle = leaderboardsModel.state {
            leaderboardsModel.fetchPreviews()
        }
    }
}

#Preview("Success") {
    NavigationStack {
        TournamentDashboard(
            tournament: .mock,
            matchesViewModel: .init(state: .success([.mock]), dataService: MatchDataServiceMock()),
            leaderboardViewModel: .init(state: .success([.mock, .mock]), dataService: LeaderboardDataServiceMock())
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
            matchesViewModel: .init(state: .failure(HTTPError.mock), dataService: MatchDataServiceMock()),
            leaderboardViewModel: .init(state: .failure(HTTPError.mock), dataService: LeaderboardDataServiceMock())
        )
    }
}
