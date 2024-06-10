//
//  TournamentsView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

struct TournamentsView: View {
    @ObservedObject private var viewModel: TournamentsModel
    
    init(viewModel: TournamentsModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .success(let tournaments):
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(tournaments) { tournament in
                        NavigationLink {
                            TournamentDashboard(tournament: tournament)
                        } label: {
                            Image(tournament.name)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                                .padding()
                                .background(.secondary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            default:
                Color.clear
            }
        }
        .overlay {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .idle:
                Text("Nach unten ziehen um Turniere zu laden.")
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            default:
                EmptyView()
            }
        }
        .navigationTitle("Turniere")
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.fetchTournaments()
            }
        }
        .refreshable {
            viewModel.fetchTournaments()
        }
    }
}

#Preview("Success") {
    NavigationStack {
        TournamentsView(viewModel: .init(state: .success([.mock]), dataService: TournamentsDataServiceMock()))
    }
}

#Preview("Loading") {
    NavigationStack {
        TournamentsView(viewModel: .init(state: .loading, dataService: TournamentsDataServiceMock()))
    }
}

#Preview("Error") {
    NavigationStack {
        TournamentsView(viewModel: .init(state: .failure(HTTPError.mock), dataService: TournamentsDataServiceMock()))
    }
}
