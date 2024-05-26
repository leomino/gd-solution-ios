//
//  Bets.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Combine
import Foundation

class PredictionDataService: PredictionDataServiceProtocol {
    func fetchBy(username: User.ID, for matchId: Match.ID) -> AnyPublisher<Prediction?, Error> {
        guard let url = URL(string: "http://localhost:3000/api/predictions/\(username)?matchId=\(matchId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: Prediction?.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchBy(username: User.ID) -> AnyPublisher<[Prediction], Error> {
        guard let url = URL(string: "http://localhost:3000/api/predictions/\(username)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Prediction].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class PredictionDataServiceMock: PredictionDataServiceProtocol {
    func fetchBy(username: User.ID, for matchId: Match.ID) -> AnyPublisher<Prediction?, Error> {
        Just(.mock).tryMap { $0 } .eraseToAnyPublisher()
    }
    
    func fetchBy(username: User.ID) -> AnyPublisher<[Prediction], Error> {
        Just([.mock]).tryMap { $0 } .eraseToAnyPublisher()
    }
}

protocol PredictionDataServiceProtocol {
    func fetchBy(username: User.ID, for matchId: Match.ID) -> AnyPublisher<Prediction?, Error>
    func fetchBy(username: User.ID) -> AnyPublisher<[Prediction], Error>
}
