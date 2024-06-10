//
//  UserDataService.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 22.06.24.
//

import Foundation
import Combine

class UserDataService: UserDataServiceProtocol {
    func fetchUsers(ids: [User.ID]) -> AnyPublisher<[User], Error> {
        guard let url = URL.hostUrl?.appending(path: "users") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(ids)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: [User].self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class UserDataServiceMock: UserDataServiceProtocol {
    func fetchUsers(ids: [User.ID]) -> AnyPublisher<[User], Error> {
        Just([.mock]).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol UserDataServiceProtocol {
    func fetchUsers(ids: [User.ID]) -> AnyPublisher<[User], Error>
}
