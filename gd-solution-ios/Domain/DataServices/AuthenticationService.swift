//
//  Authentication.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//
import Combine
import Foundation

class AuthenticationDataService: AuthenticationDataServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        guard let url = URL(string: "http://localhost:3000/api/auth/signin") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(AuthRequest(email: email, password: password, user: nil))
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: AuthResponse.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, user: User) -> AnyPublisher<AuthResponse, Error> {
        guard let url = URL(string: "http://localhost:3000/api/auth/signup") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONCoder.encoder.encode(AuthRequest(email: email, password: password, user: user))
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .validateResponse()
            .decode(type: AuthResponse.self, decoder: JSONCoder.decoder)
            .eraseToAnyPublisher()
    }
}

class AuthenticationDataServiceMock: AuthenticationDataServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        Just(.init(user: .mock, token: "some.jwt.token")).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, user: User) -> AnyPublisher<AuthResponse, Error> {
        Just(.init(user: user, token: "some.jwt.token")).tryMap { $0 }.eraseToAnyPublisher()
    }
}

protocol AuthenticationDataServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AuthResponse, Error>
    func signUp(email: String, password: String, user: User) -> AnyPublisher<AuthResponse, Error>
}
