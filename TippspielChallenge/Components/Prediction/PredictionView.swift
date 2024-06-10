//
//  MatchPredictionView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI
import MapKit

struct PredictionView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject private var viewModel: PredictionModel
    @State private var homeTeamScore: Int?
    @State private var awayTeamScore: Int?
    
    private var match: Match
    private var onUpsert: (Match.ID, Prediction) -> Void
    
    private var stadium: Stadium {
        match.stadium
    }
    
    init(match: Match, predictionViewModel viewModel: PredictionModel = .init(), onUpsert: @escaping (Match.ID, Prediction) -> Void) {
        self.match = match
        self.onUpsert = onUpsert
        self.viewModel = viewModel
        _homeTeamScore = State(wrappedValue: match.prediction?.homeTeamScore)
        _awayTeamScore = State(wrappedValue: match.prediction?.awayTeamScore)
    }
    
    private var betInvalid: Bool {
        if let homeTeamScore = homeTeamScore, let awayTeamScore = awayTeamScore {
            return homeTeamScore < 0 && awayTeamScore < 0
        }
        return true
    }
    
    private var standing: String? {
        guard match.hasStarted else { return nil }
        return "\(match.result.homeTeamScore) zu \(match.result.awayTeamScore)"
    }
    
    private var navigationTitle: String {
        if match.alreadyOver {
            return "Bereits gelaufen"
        }
        
        if match.hasStarted {
            return "Wette ansehen"
        }
        
        if match.prediction != nil {
            return "Wette bearbeiten"
        }
        
        return "Wette setzen"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(stadium.name)
                        Spacer()
                        Text(stadium.city)
                    }
                    .font(.headline)
                    .fontWeight(.medium)
                    Map(position: .constant(.camera(.init(centerCoordinate: stadium.coordinate, distance: 1000, pitch: 40)))) {
                        Annotation(stadium.name, coordinate: stadium.coordinate, anchor: .bottomTrailing) {
                            
                        }
                    }
                    .mapStyle(.imagery(elevation: .realistic))
                    .frame(height: 225)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    HStack {
                        Text(stadium.address)
                        Spacer()
                        Text("\(stadium.capacity) Plätze")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 32) {
                    HStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Circle()
                                .overlay {
                                    Image(match.homeTeam.nameShort)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipShape(Circle())
                            
                            Text(match.homeTeam.name)
                        }
                        Text("vs.")
                        VStack(spacing: 16) {
                            Circle()
                                .overlay {
                                    Image(match.awayTeam.nameShort)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipShape(Circle())
                            
                            Text(match.awayTeam.name)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        TextField("Home Score", value: $homeTeamScore, format: .number, prompt: Text("0"))
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .medium, design: .monospaced))
                            .minimumScaleFactor(0.3)
                            .multilineTextAlignment(.center)
                            .disabled(match.hasStarted)
                        Spacer()
                        Text(":")
                        Spacer()
                        TextField("Away Score", value: $awayTeamScore, format: .number, prompt: Text("0"))
                            .keyboardType(.numberPad)
                            .font(.system(size: 48, weight: .medium, design: .monospaced))
                            .minimumScaleFactor(0.3)
                            .multilineTextAlignment(.center)
                            .disabled(match.hasStarted)
                    }
                }
                .padding()

                if case .loading = viewModel.state {
                    ProgressView()
                }
                
                if case .failure(let error) = viewModel.state {
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
                
                if !match.hasStarted {
                    Button("Wette speichern") {
                        guard let homeTeamScore, let awayTeamScore else {
                            return
                        }
                        viewModel.upsertBy(matchId: match.id, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(betInvalid || match.hasStarted)
                } else {
                    Text("\(match.currentlyPlaing ? "Stand" : "Ergebnis"): \(standing ?? "0 zu 0")")
                        .padding(8)
                        .font(.subheadline)
                        .foregroundStyle(match.currentlyPlaing ? .red : .blue)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(match.currentlyPlaing ? .red.opacity(0.15) : .blue.opacity(0.15))
                        }
                }
            }
            .padding()
        }
        .onChange(of: viewModel.state) {
            if case .success(let prediction) = viewModel.state {
                if let prediction {
                    onUpsert(match.id, prediction)
                }
                dismiss.callAsFunction()
            }
        }
        .toolbar {
            if let points = match.points {
                ToolbarItem(placement: .primaryAction) {
                    Text("+\(points)P")
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Idle") {
    NavigationStack {
        PredictionView(match: .mockOver, predictionViewModel: .init(state: .idle, dataService: PredictionDataServiceMock())) { _, _ in }
            .navigationTitle("Wette bearbeiten")
    }
}

#Preview("Loading") {
    NavigationStack {
        PredictionView(match: .mock, predictionViewModel: .init(state: .loading, dataService: PredictionDataServiceMock())) { _, _ in }
            .navigationTitle("Wette bearbeiten")
    }
}

#Preview("Error") {
    NavigationStack {
        PredictionView(match: .mock, predictionViewModel: .init(state: .failure(HTTPError.mock), dataService: PredictionDataServiceMock())) { _, _ in }
            .navigationTitle("Wette bearbeiten")
    }
}
