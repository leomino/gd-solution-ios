//
//  Users.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 28.05.24.
//

import Combine
import Foundation

class UsersDataService: UsersDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[User], Error> {
        guard let url = URL(string: "http://localhost:3000/api/users") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [User].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func fetchBy(usernameFilter: String) -> AnyPublisher<[User], Error> {
        if usernameFilter.isEmpty {
            return fetchAll()
        }
        guard let url = URL(string: "http://localhost:3000/api/users?usernameFilter=\(usernameFilter)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .validateResponse()
            .decode(type: [User].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func inviteToCommunity(communityId: Community.ID, userIds: [User.ID]) -> AnyPublisher<[User], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities/\(communityId)/invite") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(userIds)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [User].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func pinUser(in communityId: Community.ID, usernameToPin: User.ID) -> AnyPublisher<[User.ID], Error> {
        guard let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) else {
            return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
        }
        guard let url = URL(string: "http://localhost:3000/api/communities/\(communityId)/pinned?username=\(usernameToPin)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [User.ID].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class UsersDataServiceMock: UsersDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[User], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func fetchBy(usernameFilter: String) -> AnyPublisher<[User], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func inviteToCommunity(communityId: Community.ID, userIds: [User.ID]) -> AnyPublisher<[User], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func pinUser(in communityId: Community.ID, usernameToPin: User.ID) -> AnyPublisher<[User.ID], Error> {
        Just([User.mock.id]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol UsersDataServiceProtocol {
    func fetchAll() -> AnyPublisher<[User], Error>
    func fetchBy(usernameFilter: String) -> AnyPublisher<[User], Error>
    func inviteToCommunity(communityId: Community.ID, userIds: [User.ID]) -> AnyPublisher<[User], Error>
    func pinUser(in communityId: Community.ID, usernameToPin: User.ID) -> AnyPublisher<[User.ID], Error>
}
