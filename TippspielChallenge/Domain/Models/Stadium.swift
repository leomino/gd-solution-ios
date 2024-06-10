//
//  Stadium.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 14.06.24.
//
import SwiftUI
import MapKit

struct Stadium: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let capacity: Int
    let city: String
    let latitude: Double
    let longitude: Double
    let pitchWidth: Int
    let pitchLength: Int
    
    static var mock: Stadium {
        .init(id: UUID(), name: "Allianz Arena", address: "Werner-Heisenberg-Allee 25", capacity: 75000, city: "München", latitude: 48.2187944, longitude: 11.6247306, pitchWidth: 68, pitchLength: 105)
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
