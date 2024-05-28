//
//  CommunityView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

class UserSuggestionViewModel: LoadingStateModel<[User]> {
    let dataService: UsersDataServiceProtocol
    @Published var usernameFilter = ""
    
    init(dataService: UsersDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: .idle)
        
        $usernameFilter.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] usernameFilter in
                guard !usernameFilter.isEmpty else {
                    return
                }
                self?.requests.send(dataService.fetchBy(usernameFilter: usernameFilter))
            }
            .store(in: &cancellables)
    }
}

class UsersViewModel: LoadingStateModel<[User]> {
    let dataService: UsersDataServiceProtocol
    
    init(dataService: UsersDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    func inviteToCommunity(communityId: Community.ID, userIds: [User.ID]) {
        requests.send(dataService.inviteToCommunity(communityId: communityId, userIds: userIds))
    }
}

struct InviteToCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var suggestionViewModel: UserSuggestionViewModel
    @ObservedObject var userViewModel: UsersViewModel
    @State private var userSelection = Set<String>()
    let communityId: Community.ID
    let onInviteSucces: ([User]) -> Void
    
    init(communityId: Community.ID, usersDataService: UsersDataServiceProtocol = UsersDataService(), onInviteSucces: @escaping ([User]) -> Void) {
        self.communityId = communityId
        self.onInviteSucces = onInviteSucces
        _suggestionViewModel = ObservedObject(wrappedValue: .init(dataService: usersDataService))
        _userViewModel = ObservedObject(wrappedValue: .init(dataService: usersDataService))
    }
    
    var body: some View {
        VStack {
            TextField("Username", text: $suggestionViewModel.usernameFilter)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            switch suggestionViewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .success(let suggestions):
                List(suggestions, selection: $userSelection) { user in
                    HStack {
                        Text(user.name)
                        Spacer()
                        Text(user.username)
                    }
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(.active))
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            }
            Spacer()
            switch suggestionViewModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            default:
                EmptyView()
            }
            Button("Einladen") {
                userViewModel.inviteToCommunity(communityId: communityId, userIds: Array(userSelection))
            }
            .disabled(userSelection.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onChange(of: userViewModel.state) {
            if case .success(let invitedUsers) = userViewModel.state {
                onInviteSucces(invitedUsers)
                dismiss.callAsFunction()
            }
        }
    }
}

#Preview {
    NavigationStack {
        InviteToCommunityView(communityId: UUID(), usersDataService: UsersDataServiceMock()) { _ in }
    }
}

struct CommunityView: View {
    @State private var community: Community
    @State private var isInviteViewPresented = false
    
    init(community: Community) {
        _community = State(wrappedValue: community)
    }
    
    var body: some View {
        List(Array(community.members.sorted(by: { $0.points < $1.points }).enumerated()), id: \.offset) { index, member in
            LeaderBoardListEntry(member: member, position: index)
        }
        .sheet(isPresented: $isInviteViewPresented) {
            NavigationStack {
                InviteToCommunityView(communityId: community.id, onInviteSucces: { invitedUsers in
                    community.members.append(contentsOf: invitedUsers)
                })
                .navigationTitle("Einladen")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Einladen") {
                    isInviteViewPresented = true
                }
            }
        }
        .navigationTitle(community.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CommunityView(community: .mock)
    }
}
