//
//  CommunitiesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

class CommunitiesViewModel: LoadingStateModel<[Community]> {
    let dataService: CommunityDataServiceProtocol
    init(dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<[Community]>, dataService: CommunityDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func fetchCommunities() {
        requests.send(dataService.fetchAll())
    }
    
    func insertCommunityInStore(community: Community) {
        if case .success(var communities) = self.state {
            communities.append(community)
            self.state = .success(communities)
        }
    }
}

struct CommunitiesView: View {
    let tournament: Tournament
    @ObservedObject var viewModel: CommunitiesViewModel
    @State private var isAddCommunityPresented = false
    
    init(tournament: Tournament, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: CommunitiesViewModel(dataService: dataService))
    }
    
    init(tournament: Tournament, state: LoadingState<[Community]>, dataService: CommunityDataServiceProtocol) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Text("Nach unten ziehen um Gemeinschaften zu laden.")
            case .loading:
                ProgressView()
            case .success(let communities):
                List {
                    ForEach(communities) { community in
                        NavigationLink {
                            Text(community.name)
                        } label: {
                            CommunityListEntry(community: community)
                        }
                    }
                }
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
        }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.fetchCommunities()
            }
        }
        .navigationTitle("Meine Gemeinschaften")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                    isAddCommunityPresented = true
                }
            }
        }
        .sheet(isPresented: $isAddCommunityPresented) {
            NavigationStack {
                AddCommunityView(for: tournament, onCreateSuccess: { community in
                    viewModel.insertCommunityInStore(community: community)
                })
                .navigationTitle("Create Community")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview("Success") {
    NavigationStack {
        CommunitiesView(tournament: .mock, dataService: CommunityDataServiceMock())
    }
}

#Preview("Loading") {
    NavigationStack {
        CommunitiesView(tournament: .mock, state: .loading, dataService: CommunityDataServiceMock())
    }
}

#Preview("Failure") {
    NavigationStack {
        CommunitiesView(tournament: .mock, state: .failure(NSError.notFound), dataService: CommunityDataServiceMock())
    }
}
