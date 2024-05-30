//
//  MatchPredictionView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

struct PredictionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: PredictionViewModel
    @State private var homeTeamScore: Int?
    @State private var awayTeamScore: Int?
    var match: Match
    var onUpsert: (Match.ID, Prediction) -> Void
    
    init(match: Match, dataService: PredictionDataServiceProtocol = PredictionDataService(), onUpsert: @escaping (Match.ID, Prediction) -> Void) {
        self.match = match
        self.onUpsert = onUpsert
        _homeTeamScore = State(wrappedValue: match.prediction?.homeTeamScore)
        _awayTeamScore = State(wrappedValue: match.prediction?.awayTeamScore)
        _viewModel = ObservedObject(wrappedValue: .init(dataService: dataService))
    }
    
    init(match: Match, state: LoadingState<Prediction?>, dataService: PredictionDataServiceProtocol, onUpsert: @escaping (Match.ID, Prediction) -> Void) {
        self.match = match
        self.onUpsert = onUpsert
        _homeTeamScore = State(wrappedValue: match.prediction?.homeTeamScore)
        _awayTeamScore = State(wrappedValue: match.prediction?.awayTeamScore)
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
    }
    
    var betInvalid: Bool {
        if let homeTeamScore = homeTeamScore, let awayTeamScore = awayTeamScore {
            return homeTeamScore < 0 && awayTeamScore < 0
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
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
                Spacer()
                Text("vs.")
                Spacer()
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
                
                Text(":")
                
                TextField("Away Score", value: $awayTeamScore, format: .number, prompt: Text("0"))
                    .keyboardType(.numberPad)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button("Wette speichern") {
                guard let homeTeamScore, let awayTeamScore else {
                    return
                }
                viewModel.upsertBy(matchId: match.id, homeTeamScore: homeTeamScore, awayTeamScore: awayTeamScore)
            }
            .buttonStyle(.borderedProminent)
            .disabled(betInvalid)
        }
        .padding()
        .onChange(of: viewModel.state) {
            switch viewModel.state {
            case .success(let prediction):
                if let prediction {
                    onUpsert(match.id, prediction)
                }
                dismiss.callAsFunction()
            default:
                return
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Success") {
    NavigationStack {
        PredictionView(match: .mock, dataService: PredictionDataServiceMock()) { _, _ in }
    }
}

#Preview("Loading") {
    NavigationStack {
        PredictionView(match: .mock, state: .loading, dataService: PredictionDataServiceMock()) { _, _ in }
    }
}

#Preview("Error") {
    NavigationStack {
        PredictionView(match: .mock, state: .failure(NSError.notFound), dataService: PredictionDataServiceMock()) { _, _ in }
    }
}
