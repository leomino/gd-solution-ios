//
//  Authentication.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import Combine
import Foundation

class AuthenticationModel: ObservableObject {
    @Published public var state: AuthenticationState = .unauthenticated
    private let dataService: AuthenticationDataServiceProtocol
    private var requests = PassthroughSubject<AnyPublisher<AuthResponse, Error>, Never>()
    private var cancellables = Set<AnyCancellable>()
    public static var TOKEN = "token"
    public static var USERNAME = "username"
    
    public init(
        dataService: AuthenticationDataServiceProtocol = AuthenticationDataService()
    ) {
        self.dataService = dataService
        setupRequestPublisher()
    }

    public init(
        state: AuthenticationState,
        dataService: AuthenticationDataServiceProtocol = AuthenticationDataService()
    ) {
        self.dataService = dataService
        self.state = state
        setupRequestPublisher()
    }

    private func setupRequestPublisher() {
        requests
            .flatMap {
                self.state = .pending
                return $0
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error)
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] result in
                self?.state = .authenticated(token: result.token, username: result.user.username)
            }
            .store(in: &cancellables)
    }
    
    public func signin(email: String, password: String) {
        requests.send(dataService.signIn(email: email, password: password))
    }
    
    public func signup(email: String, password: String, user: User) {
        requests.send(dataService.signUp(email: email, password: password, user: user))
    }
}
