//
//  Prediction.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

class PredictionViewModel: LoadingStateModel<Prediction?> {
    let dataService: PredictionDataServiceProtocol
    
    init(dataService: PredictionDataServiceProtocol = PredictionDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<Prediction?>, dataService: PredictionDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func upsertBy(matchId: Match.ID, homeTeamScore: Int, awayTeamScore: Int) {
        requests.send(dataService.upsertBy(
            matchId: matchId,
            prediction: .init(homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore))
        )
    }
}
