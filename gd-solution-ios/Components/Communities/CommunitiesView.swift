//
//  CommunitiesView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 15.05.24.
//

import SwiftUI

struct CommunitiesView: View {
    let tournament: Tournament
    @ObservedObject var viewModel: CommunitiesModel
    @ObservedObject var suggestionModel: CommunitySuggestionModel
    @State private var isCreateCommunityPresented = false
    @State private var isJoinCommunityPresented = false
    
    init(tournament: Tournament, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: .init(dataService: dataService))
        _suggestionModel = ObservedObject(wrappedValue: .init(dataService: dataService))
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
                            HStack {
                                Text(community.name)
                                Spacer()
                            }
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
        .refreshable {
            viewModel.fetchCommunities()
        }
        .navigationTitle("Meine Gemeinschaften")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button("Gruppe erstellen") {
                        isCreateCommunityPresented = true
                    }
                    Button("Gruppe beitreten") {
                        isJoinCommunityPresented = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isCreateCommunityPresented) {
            NavigationStack {
                AddCommunityView(for: tournament, onCreateSuccess: { community in
                    viewModel.insertCommunityInStore(community: community)
                })
                .navigationTitle("Gruppe erstellen")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isJoinCommunityPresented) {
            NavigationStack {
                JoinCommunityView(onJoinSuccess: { joined in
                    viewModel.insertCommunityInStore(community: joined)
                })
                .navigationTitle("Gruppe beitreten")
            }
        }
    }
}

#Preview("Success") {
    NavigationStack {
        CommunitiesView(tournament: .mock, dataService: CommunityDataServiceMock())
    }
}

//#Preview("Loading") {
//    NavigationStack {
//        CommunitiesView(tournament: .mock, state: .loading, dataService: CommunityDataServiceMock())
//    }
//}
//
//#Preview("Failure") {
//    NavigationStack {
//        CommunitiesView(tournament: .mock, state: .failure(NSError.notFound), dataService: CommunityDataServiceMock())
//    }
//}
