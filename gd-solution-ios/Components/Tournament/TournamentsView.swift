//
//  TournamentsView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

class TournamentsViewModel: LoadingStateModel<[Tournament]> {
    let dataSercice: TournamentsDataServiceProtocol
    init(dataSercice: TournamentsDataServiceProtocol = TournamentsDataService()) {
        self.dataSercice = dataSercice
        super.init(publisher: dataSercice.fetchAll())
    }
    
    func fetchTournaments() {
        requests.send(dataSercice.fetchAll())
    }
}

struct TournamentsView: View {
    @ObservedObject var viewModel: TournamentsViewModel
    
    init(dataService: TournamentsDataServiceProtocol = TournamentsDataService()) {
        _viewModel = ObservedObject(wrappedValue: TournamentsViewModel(dataSercice: dataService))
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .idle:
                Text("Nach unten ziehen um Spiele zu laden.")
            case .loading:
                ProgressView()
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
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Tournaments")
        .refreshable {
            viewModel.fetchTournaments()
        }
    }
}

#Preview {
    NavigationStack {
        TournamentsView(dataService: TournamentsDataServiceMock())
    }
}
