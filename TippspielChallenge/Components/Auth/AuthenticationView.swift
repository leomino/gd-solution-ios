//
//  AuthenticationView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 26.05.24.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var authModel: AuthenticationModel
    @State private var mode: Mode
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var supports: Team? = nil
    
    var submitDisabled: Bool {
        switch mode {
        case .signIn:
            return email.isEmpty || password.isEmpty
        case .signUp:
            return email.isEmpty || password.isEmpty || username.isEmpty || name.isEmpty
        }
    }
    
    init(mode: Mode = .signIn, authModel: AuthenticationModel = .init()) {
        self.authModel = authModel
        _mode = State(wrappedValue: mode)
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
                
                NavigationLink {
                    TeamSelection(selection: $supports)
                        .navigationTitle("Wähle deine Mannschaft aus")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HStack {
                        Circle()
                            .fill(.clear)
                            .frame(width: 30)
                            .overlay {
                                if let nameShort = supports?.nameShort {
                                    Image(nameShort)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundStyle(.blue)
                                }
                            }
                            .clipShape(Circle())
                        Text(supports != nil ? supports!.name : "Wähle deine Mannschaft aus")
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.primary.opacity(0.15))
                            .fill(.clear)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
            VStack(spacing: 32) {
                switch authModel.state {
                case .pending:
                    ProgressView()
                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                default:
                    EmptyView()
                }
                
                Button(mode.title) {
                    switch mode {
                    case .signIn:
                        authModel.signin(email: email, password: password)
                    case .signUp:
                        authModel.signup(
                            email: email,
                            password: password,
                            user: .init(username: username, name: name, supports: supports)
                        )
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

extension AuthenticationView {
    enum Mode {
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
}

#Preview("Sign in (idle)") {
    NavigationStack {
        AuthenticationView(authModel: .init(dataService: AuthenticationDataServiceMock()))
    }
}

#Preview("Sign in (pending)") {
    NavigationStack {
        AuthenticationView(authModel: .init(state: .pending, dataService: AuthenticationDataServiceMock()))
    }
}

#Preview("Sign in (error)") {
    NavigationStack {
        AuthenticationView(authModel: .init(
            state: .failure(HTTPError.init(errorDescription: "Invalid email")),
            dataService: AuthenticationDataServiceMock())
        )
    }
}

#Preview("Sign up (idle)") {
    NavigationStack {
        AuthenticationView(mode: .signUp, authModel: .init(dataService: AuthenticationDataServiceMock()))
    }
}

#Preview("Sign up (pending)") {
    NavigationStack {
        AuthenticationView(mode: .signUp, authModel: .init(state: .pending, dataService: AuthenticationDataServiceMock()))
    }
}

#Preview("Sign up (error)") {
    NavigationStack {
        AuthenticationView(mode: .signUp, authModel: .init(state: .failure(HTTPError.mock), dataService: AuthenticationDataServiceMock()))
    }
}
