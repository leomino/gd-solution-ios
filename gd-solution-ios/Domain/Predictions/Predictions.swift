//
//  Bets.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Combine
import Foundation

class PredictionDataService: PredictionDataServiceProtocol {
    func fetchBy(matchId: Match.ID) -> AnyPublisher<Prediction?, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/predictions?matchId=\(matchId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: Prediction?.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchBy(matchIds: [Match.ID]) -> AnyPublisher<[Prediction], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/predictions") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(matchIds)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [Prediction].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class PredictionDataServiceMock: PredictionDataServiceProtocol {
    func fetchBy(matchId: Match.ID) -> AnyPublisher<Prediction?, Error> {
        Just(.mock).tryMap { $0 } .eraseToAnyPublisher()
    }
    
    func fetchBy(matchIds: [Match.ID]) -> AnyPublisher<[Prediction], Error> {
        Just([.mock]).tryMap { $0 } .eraseToAnyPublisher()
    }
}

protocol PredictionDataServiceProtocol {
    func fetchBy(matchId: Match.ID) -> AnyPublisher<Prediction?, Error>
    func fetchBy(matchIds: [Match.ID]) -> AnyPublisher<[Prediction], Error>
}
