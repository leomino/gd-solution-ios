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

class CommunitySuggestionModel: LoadingStateModel<[Community]> {
    let dataService: CommunityDataServiceProtocol
    @Published var searchString = ""
    
    init(dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
        
        $searchString.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchString in
                guard !searchString.isEmpty else {
                    return
                }
                self?.requests.send(dataService.searchBy(searchString: searchString))
            }
            .store(in: &cancellables)
    }
}

struct JoinCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var communityModel: CommunityViewModel
    @ObservedObject var suggestionModel: CommunitySuggestionModel
    @State private var selectedCommunityId: UUID?
    let onJoinSuccess: (Community) -> Void
    
    init(dataService: CommunityDataServiceProtocol = CommunityDataService(), onJoinSuccess: @escaping (Community) -> Void) {
        self.onJoinSuccess = onJoinSuccess
        _suggestionModel = ObservedObject(wrappedValue: .init(dataService: dataService))
        _communityModel = ObservedObject(wrappedValue: .init(dataService: dataService))
    }
    
    var body: some View {
        VStack {
            TextField("Gruppe suchen", text: $suggestionModel.searchString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            switch suggestionModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .success(let suggestions):
                List(suggestions, selection: $selectedCommunityId) { community in
                    HStack {
                        Text(community.name)
                        Spacer()
                        Text(community.tournament.name)
                    }
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(.active))
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
            Spacer()
            switch suggestionModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            default:
                EmptyView()
            }
            Button("Beitreten") {
                guard let selectedCommunityId else {
                    return
                }
                communityModel.joinCommunity(communityId: selectedCommunityId)
                
            }
            .disabled(selectedCommunityId == nil)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        JoinCommunityView { _ in
            
        }
        .navigationTitle("Gruppe beitreten")
    }
}

struct CommunitiesView: View {
    let tournament: Tournament
    @ObservedObject var viewModel: CommunitiesViewModel
    @ObservedObject var suggestionModel: CommunitySuggestionModel
    @State private var isCreateCommunityPresented = false
    @State private var isJoinCommunityPresented = false
    
    init(tournament: Tournament, dataService: CommunityDataServiceProtocol = CommunityDataService()) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: .init(dataService: dataService))
        _suggestionModel = ObservedObject(wrappedValue: .init(dataService: dataService))
    }
    
    init(tournament: Tournament, state: LoadingState<[Community]>, dataService: CommunityDataServiceProtocol) {
        self.tournament = tournament
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
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
