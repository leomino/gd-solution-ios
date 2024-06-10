//
//  MatchResultModel.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 23.06.24.
//

class MatchResultModel: LoadingStateModel<MatchResult> {
    let dataService: MatchResultDataServiceProtocol
    
    init(state: LoadingState<MatchResult> = .idle, dataService: MatchResultDataServiceProtocol = MatchResultDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func update(matchResult: MatchResult) {
        requests.send(dataService.update(matchResult: matchResult))
    }
    
    func triggerRankCalculation(for matchResult: MatchResult) {
        dataService.triggerRankCalculation(for: matchResult)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
