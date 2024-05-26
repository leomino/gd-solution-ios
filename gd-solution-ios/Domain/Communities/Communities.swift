//
//  Communities.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Combine
import Foundation

class CommunityDataService: CommunityDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Community], Error> {
        guard let url = URL(string: "http://localhost:3000/api/communities") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Community].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class CommunityDataServiceMock: CommunityDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Community], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol CommunityDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Community], Error>
}
