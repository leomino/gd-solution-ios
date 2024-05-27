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
                if case .authenticated(_, let token) = authModel.state {
                    UserDefaults.standard.set(token, forKey: "token")
                }
            }
        }
    }
}

#Preview {
    ContentView(authModel: .init(dataService: AuthenticationDataServiceMock()))
}
