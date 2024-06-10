//
//  TournamentsModel.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

class TournamentsModel: LoadingStateModel<[Tournament]> {
    let dataService: TournamentsDataServiceProtocol
    init(state: LoadingState<[Tournament]> = .idle, dataService: TournamentsDataServiceProtocol = TournamentsDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchTournaments() {
        requests.send(dataService.fetchAll())
    }
}
