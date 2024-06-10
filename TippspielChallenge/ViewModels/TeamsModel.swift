//
//  TeamsModel.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 16.06.24.
//

class TeamsModel: LoadingStateModel<[Team]> {
    let dataService: TeamsDataServiceProtocol
 
    init(state: LoadingState<[Team]> = .idle, dataService: TeamsDataServiceProtocol = TeamsDataService()) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchTeams() {
        requests.send(dataService.fetchAll())
    }
}
