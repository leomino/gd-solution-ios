//
//  MatchPredictionView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 14.05.24.
//

import SwiftUI

class PredictionViewModel: LoadingStateModel<Prediction?> {
    let dataService: PredictionDataServiceProtocol
    @Published var homeTeamScore: Int?
    @Published var awayTeamScore: Int?
    
    init(dataService: PredictionDataServiceProtocol = PredictionDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<Prediction?>, dataService: PredictionDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchPredictionBy(matchId: Match.ID) {
        requests.send(dataService.fetchBy(matchId: matchId))
    }
}

struct PredictionView: View {
    @ObservedObject private var viewModel: PredictionViewModel
    var match: Match
    
    init(match: Match, dataService: PredictionDataServiceProtocol = PredictionDataService()) {
        self.match = match
        _viewModel = ObservedObject(wrappedValue: .init(dataService: dataService))
    }
    
    init(match: Match, state: LoadingState<Prediction?>, dataService: PredictionDataServiceProtocol) {
        self.match = match
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
    }
    
    var betInvalid: Bool {
        if let homeTeamScore = viewModel.homeTeamScore, let awayTeamScore = viewModel.awayTeamScore {
            return homeTeamScore < 0 && awayTeamScore < 0
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 32) {
            GeometryReader { geo in
                HStack {
                    VStack(spacing: 16) {
                        Image(match.homeTeam.nameShort)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: geo.size.width * 0.4)
                        
                        Text(match.homeTeam.name)
                    }
                    Spacer()
                    Text("vs.")
                    Spacer()
                    VStack(spacing: 16) {
                        Image(match.awayTeam.nameShort)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: geo.size.width * 0.4)
                        
                        Text(match.awayTeam.name)
                    }
                }
                .frame(width: geo.size.width)
                .aspectRatio(contentMode: .fit)
            }
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .success, .failure, .idle:
                HStack(spacing: 16) {
                    TextField("Home Score", value: $viewModel.homeTeamScore, format: .number, prompt: Text("0"))
                        .keyboardType(.numberPad)
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .minimumScaleFactor(0.3)
                        .multilineTextAlignment(.center)
                    
                    Text(":")
                    
                    TextField("Away Score", value: $viewModel.awayTeamScore, format: .number, prompt: Text("0"))
                        .keyboardType(.numberPad)
                        .font(.system(size: 48, weight: .medium, design: .monospaced))
                        .minimumScaleFactor(0.3)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button("Wette speichern") { }
                    .disabled(betInvalid)
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchPredictionBy(matchId: match.id)
        }
        .onChange(of: viewModel.state) {
            switch viewModel.state {
            case .success(let prediction):
                if let awayScore = prediction?.awayTeamScore, let homeScore = prediction?.homeTeamScore {
                    viewModel.awayTeamScore = awayScore
                    viewModel.homeTeamScore = homeScore
                }
            default:
                return
            }
        }
        .navigationTitle(String(describing: match.startAtFormatted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Success") {
    NavigationStack {
        PredictionView(match: .mock, dataService: PredictionDataServiceMock())
    }
}

#Preview("Loading") {
    NavigationStack {
        PredictionView(match: .mock, state: .loading, dataService: PredictionDataServiceMock())
    }
}

#Preview("Error") {
    NavigationStack {
        PredictionView(match: .mock, state: .failure(NSError.notFound), dataService: PredictionDataServiceMock())
    }
}
