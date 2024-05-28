//
//  MatchesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

class MatchDayViewModel: LoadingStateModel<[MatchDay]> {
    let dataService: MatchDayDataServiceProtocol
    init(dataService: MatchDayDataServiceProtocol = MatchDayDataService()) {
        self.dataService = dataService
        super.init(publisher: dataService.fetchAll())
    }
    
    init(state: LoadingState<[MatchDay]>, dataService: MatchDayDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchMatches() {
        requests.send(dataService.fetchAll())
    }
    
    func upsertPredictionInStore(for matchId: Match.ID, with prediction: Prediction) {
        if case .success(var matchDays) = state {
            if let matchDayIndex = matchDays.firstIndex(where: { $0.matches.contains(where: { match in match.id == matchId }) }) {
                var matches = matchDays[matchDayIndex].matches
                if let index = matches.firstIndex(where: { $0.id == matchId }) {
                    matches[index].prediction = prediction
                }
                matchDays[matchDayIndex].matches = matches
                state = .success(matchDays)
            }
        }
    }
}

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
