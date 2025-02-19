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
    
    @State private var isCreateCommunityPresented = false
    @State private var isJoinCommunityPresented = false
    
    init(tournament: Tournament, viewModel: CommunitiesModel = .init()) {
        self.tournament = tournament
        self.viewModel = viewModel
    }
    
    var addNewGroupsDisabled: Bool {
        if case .success(let t) = viewModel.state {
            return t.count >= 5
        }
        return false
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
                            LeaderboardLoadingView(communityId: community.id)
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
                    .foregroundStyle(.secondary)
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
                    .disabled(addNewGroupsDisabled)
                    Button("Gruppe beitreten") {
                        isJoinCommunityPresented = true
                    }
                    .disabled(addNewGroupsDisabled)
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
            }
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
        CommunitiesView(tournament: .mock, viewModel: .init(state: .success([.mock]), dataService: CommunityDataServiceMock()))
    }
}

#Preview("Loading") {
    NavigationStack {
        CommunitiesView(tournament: .mock, viewModel: .init(state: .loading, dataService: CommunityDataServiceMock()))
    }
}

#Preview("Error") {
    NavigationStack {
        CommunitiesView(tournament: .mock, viewModel: .init(state: .failure(HTTPError.mock), dataService: CommunityDataServiceMock()))
    }
}
