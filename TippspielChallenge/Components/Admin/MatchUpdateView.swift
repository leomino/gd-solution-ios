//
//  MatchUpdateView.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 23.06.24.
//

import SwiftUI

struct MatchUpdateView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: MatchResultModel
    
    @State private var homeTeamScore: Int
    @State private var awayTeamScore: Int
    @State private var finalized: Bool
    
    private var match: Match
    private var onUpdate: (MatchResult) -> Void
    
    init(viewModel: MatchResultModel = .init(), match: Match, onUpdate: @escaping (MatchResult) -> Void) {
        self.viewModel = viewModel
        self.match = match
        self.onUpdate = onUpdate
        _homeTeamScore = State(wrappedValue: match.result.homeTeamScore)
        _awayTeamScore = State(wrappedValue: match.result.awayTeamScore)
        _finalized = State(wrappedValue: match.result.finalized)
    }
    
    var formInvalid: Bool {
        return homeTeamScore < 0 && awayTeamScore < 0
    }
    
    var body: some View {
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
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                TextField("Home Score", value: $homeTeamScore, format: .number, prompt: Text("0"))
                    .keyboardType(.numberPad)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)
                Spacer()
                Text(":")
                Spacer()
                TextField("Away Score", value: $awayTeamScore, format: .number, prompt: Text("0"))
                    .keyboardType(.numberPad)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading) {
                Toggle(isOn: $finalized) {
                    Text("Spiel vorbei")
                        .font(.headline)
                }
                Text("Das setzen des Flags updated die Punkte aller Spieler die eine erfolgreiche Wette für das Spiel gesetzt haben.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if case .loading = viewModel.state {
                ProgressView()
            }
        
            if case .failure(let error) = viewModel.state {
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
            
            Button("Speichern") {
                viewModel.update(matchResult: .init(
                    matchId: match.id,
                    homeTeamScore: homeTeamScore,
                    awayTeamScore: awayTeamScore,
                    finalized: finalized
                ))
            }
            .buttonStyle(.borderedProminent)
            .disabled(formInvalid)
        }
        .padding()
        .onChange(of: viewModel.state) {
            if case .success(let result) = viewModel.state {
                onUpdate(result)
                if result.finalized {
                    viewModel.triggerRankCalculation(for: result)
                }
                dismiss.callAsFunction()
            }
        }
    }
}

#Preview {
    MatchUpdateView(match: .mock) { _ in }
}
