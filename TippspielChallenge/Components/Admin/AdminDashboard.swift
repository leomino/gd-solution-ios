//
//  AdminDashboard.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 23.06.24.
//

import SwiftUI

struct AdminDashboard: View {
    @StateObject var viewModel: MatchDayModel
    @State private var selectedMatch: Match? = nil
    
    init(viewModel: MatchDayModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Text("Spiele werden geladen...")
                        .onAppear {
                            if case .idle = viewModel.state {
                                viewModel.fetchMatches()
                            }
                        }
                case .loading:
                    ProgressView()
                case .success(let matchDays):
                    List {
                        ForEach(matchDays) { matchDay in
                            Section(matchDay.dateRangeFormatted) {
                                ForEach(matchDay.matches) { match in
                                    MatchListEntry(match: match, showPoints: false)
                                        .onTapGesture {
                                            selectedMatch = match
                                        }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
            }
            .refreshable {
                viewModel.fetchMatches()
            }
            .sheet(item: $selectedMatch) { match in
                NavigationStack {
                    MatchUpdateView(match: match, onUpdate: { result in
                        viewModel.updateResultInStore(matchResult: result)
                    })
                    .navigationTitle("Ergebnis bearbeiten")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    AdminDashboard(viewModel: .init(state: .success([.mock]), dataService: MatchDayDataServiceMock()))
}
