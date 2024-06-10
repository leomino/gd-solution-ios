//
//  ContentView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 06.05.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authModel: AuthenticationModel
    
    init(authModel: AuthenticationModel = AuthenticationModel()) {
        _authModel = StateObject(wrappedValue: authModel)
        if let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN),
           let username = UserDefaults.standard.string(forKey: AuthenticationModel.USERNAME),
           let role = UserDefaults.standard.string(forKey: AuthenticationModel.ROLE) {
            authModel.state = .authenticated(token: token, username: username, role: role)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch authModel.state {
                case .authenticated:
                    TournamentsView()
                default:
                    AuthenticationView(authModel: authModel)
                }
            }
            .onChange(of: authModel.state) {
                if case .unauthenticated = authModel.state {
                    UserDefaults.standard.removeObject(forKey: AuthenticationModel.USERNAME)
                    UserDefaults.standard.removeObject(forKey: AuthenticationModel.TOKEN)
                    UserDefaults.standard.removeObject(forKey: AuthenticationModel.ROLE)
                    return
                }
                
                if case .authenticated(let token, let username, let role) = authModel.state {
                    UserDefaults.standard.set(username, forKey: AuthenticationModel.USERNAME)
                    UserDefaults.standard.set(token, forKey: AuthenticationModel.TOKEN)
                    UserDefaults.standard.set(role, forKey: AuthenticationModel.ROLE)
                    return
                }
            }
            .toolbar {
                if case .authenticated = authModel.state {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Logout", action: { authModel.state = .unauthenticated })
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(authModel: .init(dataService: AuthenticationDataServiceMock()))
}
