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
        if let token = UserDefaults.standard.string(forKey: AuthenticationModel.TOKEN) {
            authModel.state = .authenticated(token: token)
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
                if case .authenticated(let token) = authModel.state {
                    UserDefaults.standard.set(token, forKey: AuthenticationModel.TOKEN)
                }
            }
            .toolbar {
                if case .authenticated = authModel.state {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Logout") {
                            UserDefaults.standard.removeObject(forKey: AuthenticationModel.TOKEN)
                            authModel.state = .unauthenticated
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(authModel: .init(dataService: AuthenticationDataServiceMock()))
}
