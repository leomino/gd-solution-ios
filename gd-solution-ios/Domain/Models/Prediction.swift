//
//  Bet.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import Foundation

struct Prediction: Codable, Equatable {
    let homeTeamScore: Int
    let awayTeamScore: Int
    
    static var mock: Prediction {
        .init(homeTeamScore: 0, awayTeamScore: 2)
    }
}
