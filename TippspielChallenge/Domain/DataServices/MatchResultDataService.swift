//
//  MatchResultDataService.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 23.06.24.
//

import Foundation
import Combine

class MatchResultDataService: MatchResultDataServiceProtocol {
    func update(matchResult: MatchResult) -> AnyPublisher<MatchResult, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL.hostUrl?.appending(path: "results") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(matchResult)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: MatchResult.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func triggerRankCalculation(for matchResult: MatchResult) -> AnyPublisher<[Int], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL.hostUrl?.appending(path: "results") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(matchResult)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [Int].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class MatchResultDataServiceMock {
    func update(matchResult: MatchResult) -> AnyPublisher<MatchResult, Error> {
        Just(.mock).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func triggerRankCalculation(for matchResult: MatchResult) -> AnyPublisher<[Int], Error> {
        Just([1, 2, 3]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol MatchResultDataServiceProtocol {
    func update(matchResult: MatchResult) -> AnyPublisher<MatchResult, Error>
    func triggerRankCalculation(for matchResult: MatchResult) -> AnyPublisher<[Int], Error>
}
