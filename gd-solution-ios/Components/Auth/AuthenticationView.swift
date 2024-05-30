//
//  AuthenticationView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 26.05.24.
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authModel: AuthenticationModel
    @State private var mode = Mode.signIn
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var username: String = ""
    @State private var name: String = ""
    
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
                        authModel.signup(
                            email: email,
                            password: password,
                            user: .init(username: username, name: name)
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

#Preview("Unauthenticated") {
    NavigationStack {
        AuthenticationView(authModel: .init(state: .unauthenticated, dataService: AuthenticationDataServiceMock()))
    }
}
