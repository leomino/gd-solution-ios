//
//  MatchesDataServiceProtocol.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Combine
import Foundation

class MatchDataService: MatchDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Match], Error> {
        guard let url = URL(string: "http://localhost:3000/api/matches") else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Match].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchNext() -> AnyPublisher<[Match], Error> {
        guard let url = URL(string: "http://localhost:3000/api/matches/next") else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Match].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchBy(matchDayId id: Match.ID) -> AnyPublisher<[Match], Error> {
        guard let url = URL(string: "http://localhost:3000/api/matches/\(id)") else {
                    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [Match].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class MatchDataServiceMock: MatchDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Match], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func fetchNext() -> AnyPublisher<[Match], Error> {
        Just([.mockCurrentlyPlaying, .mockPlayingInMinutes, .mockPlayingToday]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func fetchBy(matchDayId id: Match.ID) -> AnyPublisher<[Match], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol MatchDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Match], Error>
    func fetchNext() -> AnyPublisher<[Match], Error>
    func fetchBy(matchDayId id: Match.ID) -> AnyPublisher<[Match], Error>
}
