//
//  TournamentsModel.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

class TournamentsModel: LoadingStateModel<[Tournament]> {
    let dataSercice: TournamentsDataServiceProtocol
    init(dataSercice: TournamentsDataServiceProtocol = TournamentsDataService()) {
        self.dataSercice = dataSercice
        super.init(state: .idle)
    }
    
    func fetchTournaments() {
        requests.send(dataSercice.fetchAll())
    }
}
