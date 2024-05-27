//
//  AuthenticationView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 26.05.24.
//

import SwiftUI

import Combine

enum AuthenticationState: Equatable {
    case pending
    case authenticated(token: String)
    case unauthenticated
    case failure(Error)
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending), (.unauthenticated, .unauthenticated):
            return true
        case let (.authenticated(lhsValue), .authenticated(rhsValue)):
            return lhsValue == rhsValue
        case let (.failure(lhsError as NSError), .failure(rhsError as NSError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct AuthRequest: Codable {
    let email: String
    let password: String
    let user: User?
}

class AuthenticationDataServiceMock: AuthenticationDataServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AuthResponse, Error> {
        Just(.init(user: .mock, token: "some.jwt.token")).tryMap { $0 }.eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, user: User) -> AnyPublisher<AuthResponse, Error> {
        Just(.init(user: user, token: "some.jwt.token")).tryMap { $0 }.eraseToAnyPublisher()
    }
}

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

protocol AuthenticationDataServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<AuthResponse, Error>
    func signUp(email: String, password: String, user: User) -> AnyPublisher<AuthResponse, Error>
}

class AuthenticationModel: ObservableObject {
    @Published public var state: AuthenticationState = .unauthenticated
    private let dataService: AuthenticationDataServiceProtocol
    private var requests = PassthroughSubject<AnyPublisher<AuthResponse, Error>, Never>()
    private var cancellables = Set<AnyCancellable>()
    public static var TOKEN = "token"
    
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
                self?.state = .authenticated(token: result.token)
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

enum AuthenticationViewMode {
    case signIn, signUp
    
    var title: String {
        switch self {
        case .signIn:
            "Anmelden"
        case .signUp:
            "Registrieren"
        }
    }
    
    var switchModeLabel: String {
        switch self {
        case .signIn:
            "Noch keinen Account?"
        case .signUp:
            "Schon registriert?"
        }
    }
}

struct AuthenticationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authModel: AuthenticationModel
    @State private var mode = AuthenticationViewMode.signIn
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var supports: Team?
    
    var submitDisabled: Bool {
        switch mode {
        case .signIn:
            return email.isEmpty || password.isEmpty
        case .signUp:
            return email.isEmpty || password.isEmpty || username.isEmpty || name.isEmpty
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            TextField("Email", text: $email)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            if case .signUp = mode {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
            }
            Spacer()
            VStack(spacing: 32) {
                switch authModel.state {
                case .pending:
                    ProgressView()
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                default:
                    EmptyView()
                }
                
                Button(mode.title) {
                    switch mode {
                    case .signIn:
                        authModel.signin(email: email, password: password)
                    case .signUp:
                        authModel.signup(email: email, password: password, user: .init(username: username, name: name, supports: supports, points: 0))
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(submitDisabled)
                
                Button(mode.switchModeLabel) {
                    switch mode {
                    case .signIn:
                        mode = .signUp
                    case .signUp:
                        mode = .signIn
                    }
                }
            }
        }
        .padding()
        .navigationTitle(mode.title)
    }
}

#Preview("Unauthenticated") {
    NavigationStack {
        AuthenticationView(authModel: .init(state: .unauthenticated, dataService: AuthenticationDataServiceMock()))
    }
}
