//
//  TeamsService.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 16.06.24.
//

import Foundation
import Combine

protocol TeamsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Team], Error>
}

class TeamsDataService: TeamsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Team], Error> {
        guard let url = URL.hostUrl?.appending(path: "teams") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Team].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class TeamsDataServiceMock: TeamsDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Team], Error> {
        Just([.mock, .mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}
