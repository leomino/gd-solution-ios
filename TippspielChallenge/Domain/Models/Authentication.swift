//
//  Authentication.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import Foundation

struct AuthResponse: Codable {
    let user: User
    let role: String
    let token: String
}

struct AuthRequest: Codable {
    let email: String
    let password: String
    let user: User?
}

enum AuthenticationState: Equatable {
    case pending
    case authenticated(token: String, username: String, role: String)
    case unauthenticated
    case failure(Error)
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending), (.unauthenticated, .unauthenticated):
            return true
        case let (.authenticated(lhsToken, lhsUsername, lhsRole), .authenticated(rhsToken, rhsUsername, rhsRole)):
            return lhsToken == rhsToken && lhsUsername == rhsUsername && lhsRole == rhsRole
        case let (.failure(lhsError as NSError), .failure(rhsError as NSError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
