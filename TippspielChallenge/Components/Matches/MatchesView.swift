//
//  MatchesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: MatchDayModel
    @State private var selectedMatch: Match? = nil
    
    init(viewModel: MatchDayModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Text("Nach unten ziehen um Spiele zu laden.")
                case .loading:
                    ProgressView()
                case .success(let matchDays):
                    List {
                        ForEach(matchDays) { matchDay in
                            Section {
                                ForEach(matchDay.matches) { match in
                                    MatchListEntry(match: match)
                                        .onTapGesture {
                                            selectedMatch = match
                                        }
                                }
                            } header: {
                                HStack {
                                    Text(matchDay.dateRangeFormatted)
                                    Spacer()
                                    if let points = matchDay.points {
                                        Text("Gesamt: +\(points)P")
                                    }
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Spiele")
            .onAppear {
                if case .idle = viewModel.state {
                    viewModel.fetchMatches()
                }
            }
            .refreshable {
                viewModel.fetchMatches()
            }
            .sheet(item: $selectedMatch) { match in
                NavigationStack {
                    PredictionView(match: match, onUpsert: { matchId, prediction in
                        viewModel.upsertPredictionInStore(for: matchId, with: prediction)
                    })
                }
            }
        }
    }
}

#Preview("Success") {
    MatchesView(viewModel: .init(state: .success([.mock]), dataService: MatchDayDataServiceMock()))
}

#Preview("Loading") {
    MatchesView(viewModel: MatchDayModel(state: .loading, dataService: MatchDayDataServiceMock()))
}

#Preview("Failure") {
    MatchesView(viewModel: MatchDayModel(state: .failure(HTTPError.mock), dataService: MatchDayDataServiceMock()))
}
