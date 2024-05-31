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
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [Community].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func create(_ community: Community) -> AnyPublisher<Community, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(community)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: Community.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func searchBy(searchString: String) -> AnyPublisher<[Community], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities/search?name=\(searchString)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [Community].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func join(communityId: Community.ID) -> AnyPublisher<Community, Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities/join?id=\(communityId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: Community.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class CommunityDataServiceMock: CommunityDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Community], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func searchBy(searchString: String) -> AnyPublisher<[Community], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func create(_ community: Community) -> AnyPublisher<Community, Error> {
        Just(community).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func join(communityId: Community.ID) -> AnyPublisher<Community, Error> {
        Just(.mock).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol CommunityDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[Community], Error>
    func searchBy(searchString: String) -> AnyPublisher<[Community], Error>
    func create(_ community: Community) -> AnyPublisher<Community, Error>
    func join(communityId: Community.ID) -> AnyPublisher<Community, Error>
}
