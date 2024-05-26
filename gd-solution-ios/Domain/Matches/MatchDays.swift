//
//  MatchesDataServiceProtocol.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Combine
import Foundation

class MatchDayDataService: MatchDayDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[MatchDay], Error> {
        guard let url = URL(string: "http://localhost:3000/api/match-days") else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [MatchDay].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class MatchDayDataServiceMock: MatchDayDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[MatchDay], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol MatchDayDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[MatchDay], Error>
}
