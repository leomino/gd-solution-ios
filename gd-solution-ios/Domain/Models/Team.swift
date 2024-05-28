//
//  Team.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//
import Foundation

struct Team: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let nameShort: String
        
    static var mock: Team {
        .init(id: UUID(), name: "Deutschland", nameShort: "GER")
    }
}
