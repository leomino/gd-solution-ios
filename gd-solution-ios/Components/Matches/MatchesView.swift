//
//  MatchesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel: MatchDayViewModel
    @State private var selectedMatch: Match? = nil
    
    init(dataService: MatchDayDataServiceProtocol = MatchDayDataService()) {
        _viewModel = ObservedObject(wrappedValue: MatchDayViewModel(dataService: dataService))
    }
    
    init(viewModel: MatchDayViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
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
                            Section(matchDay.dateRangeFormatted) {
                                ForEach(matchDay.matches) { match in
                                    MatchListEntry(match: match)
                                        .onTapGesture {
                                            selectedMatch = match
                                        }
                                }
                            }
                            .headerProminence(.increased)
                        }
                    }
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
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
                    .navigationTitle(match.prediction != nil ? "Wette bearbeiten" : "Wette abgeben")
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview("Success") {
    MatchesView(dataService: MatchDayDataServiceMock())
}

#Preview("Loading") {
    MatchesView(viewModel: MatchDayViewModel(state: .loading, dataService: MatchDayDataServiceMock()))
}

#Preview("Failure") {
    MatchesView(viewModel: MatchDayViewModel(state: .failure(NSError.notFound), dataService: MatchDayDataServiceMock()))
}
