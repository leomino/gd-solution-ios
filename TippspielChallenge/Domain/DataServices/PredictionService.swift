//
//  Bets.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 25.05.24.
//

import Combine
import Foundation

class PredictionDataService: PredictionDataServiceProtocol {
    func upsertBy(matchId: Match.ID, prediction: Prediction) -> AnyPublisher<Prediction?, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL.hostUrl?.appending(path: "predictions").appending(queryItems: [.init(name: "matchId", value: "\(matchId)")]) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(prediction)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: Prediction?.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class PredictionDataServiceMock: PredictionDataServiceProtocol {
    func upsertBy(matchId: Match.ID, prediction: Prediction) -> AnyPublisher<Prediction?, Error> {
        Just(.mock).tryMap { $0 } .eraseToAnyPublisher()
    }
}

protocol PredictionDataServiceProtocol {
    func upsertBy(matchId: Match.ID, prediction: Prediction) -> AnyPublisher<Prediction?, Error>
}
