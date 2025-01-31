//
//  MatchDay.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

class MatchDayModel: LoadingStateModel<[MatchDay]> {
    let dataService: MatchDayDataServiceProtocol
    
    init(state: LoadingState<[MatchDay]> = .idle, dataService: MatchDayDataServiceProtocol = MatchDayDataService()) {
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
    
    func updateResultInStore(matchResult: MatchResult) {
        if case .success(var matchDays) = state {
            let matchId = matchResult.matchId
            if let matchDayIndex = matchDays.firstIndex(where: { $0.matches.contains(where: { match in match.id == matchId }) }) {
                var matches = matchDays[matchDayIndex].matches
                if let index = matches.firstIndex(where: { $0.id == matchId }) {
                    matches[index].result = matchResult
                }
                matchDays[matchDayIndex].matches = matches
                state = .success(matchDays)
            }
        }
    }
}
