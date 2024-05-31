//
//  Leaderboards.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 30.05.24.
//

import Foundation
import Combine

class LeaderboardDataService: LeaderboardDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Leaderboard], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/leaderboards") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [Leaderboard].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchBy(_ communityId: Community.ID) -> AnyPublisher<Leaderboard, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/leaderboards/\(communityId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: Leaderboard.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchPagination(
        in communityId: Community.ID,
        offset: Int,
        limit: Int,
        type: LeaderboardPaginationModel.RequestType,
        at: Int
    ) -> AnyPublisher<([LeaderboardEntry], LeaderboardPaginationModel.RequestType, Int), Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/leaderboards/\(communityId)/pages?offset=\(offset)&limit=\(limit)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [LeaderboardEntry].self, decoder: JSONCoder.decoder)
            .map { entries in
                (entries, type, at)
            }
            .eraseToAnyPublisher()
    }
    
    func searchEntries(in communityId: Community.ID, with usernameFilter: String) -> AnyPublisher<[LeaderboardEntry], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/leaderboards/\(communityId)/user-search?searchString=\(usernameFilter)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [LeaderboardEntry].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class LeaderboardDataServiceMock: LeaderboardDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Leaderboard], Error> {
        Just([.mock, .mock, .mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func fetchBy(_ communityId: Community.ID) -> AnyPublisher<Leaderboard, Error> {
        Just(.mock).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func fetchPagination(
        in communityId: Community.ID,
        offset: Int,
        limit: Int,
        type: LeaderboardPaginationModel.RequestType,
        at: Int
    ) -> AnyPublisher<([LeaderboardEntry], LeaderboardPaginationModel.RequestType, Int), Error> {
        Just(([LeaderboardEntry.mock(position: 1)], .next, 1)).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func searchEntries(in communityId: Community.ID, with usernameFilter: String) -> AnyPublisher<[LeaderboardEntry], Error> {
        Just([.mock(position: 1), .mock(position: 2), .mock(position: 3)]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol LeaderboardDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Leaderboard], Error>
    func fetchBy(_ communityId: Community.ID) -> AnyPublisher<Leaderboard, Error>
    func fetchPagination(
        in communityId: Community.ID,
        offset: Int,
        limit: Int,
        type: LeaderboardPaginationModel.RequestType,
        at: Int
    ) -> AnyPublisher<([LeaderboardEntry], LeaderboardPaginationModel.RequestType, Int), Error>
    func searchEntries(in communityId: Community.ID, with usernameFilter: String) -> AnyPublisher<[LeaderboardEntry], Error>
}
