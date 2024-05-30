//
//  Tournaments.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Combine
import Foundation

class TournamentsDataService: TournamentsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Tournament], Error> {
        guard let url = URL(string: "http://localhost:3000/api/tournaments") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Tournament].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class TournamentsDataServiceMock: TournamentsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Tournament], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol TournamentsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Tournament], Error>
}
