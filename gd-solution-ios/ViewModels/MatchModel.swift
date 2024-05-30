//
//  Matches.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

class MatchesViewModel: LoadingStateModel<[Match]> {
    let dataService: MatchDataServiceProtocol
    init(dataService: MatchDataServiceProtocol = MatchDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
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
    
    func upsertPredictionInStore(for matchId: Match.ID, with prediction: Prediction) {
        if case .success(var matches) = state {
            if let index = matches.firstIndex(where: { $0.id == matchId }) {
                matches[index].prediction = prediction
            }
            state = .success(matches)
        }
    }
}
