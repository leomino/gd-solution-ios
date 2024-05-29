//
//  CommunityView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 16.05.24.
//

import SwiftUI

import Combine
class UserLocalSuggestionViewModel: ObservableObject {
    @Published var filtered: [(User, Int)]
    @Published var userFilter = ""
    public var cancellables = Set<AnyCancellable>()
    
    init(data: [User]) {
        let leaderBoardData = data.sorted(by: { $0.points < $1.points }).enumerated().map { ($1, $0) }
        self.filtered = leaderBoardData
        
        $userFilter.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                guard let self else {
                    return
                }
                guard !filter.isEmpty else {
                    self.filtered = leaderBoardData
                    return
                }
                self.filtered = leaderBoardData.filter { (user, _) in
                    user.username.lowercased().contains(filter.lowercased()) || user.name.lowercased().contains(filter.lowercased())
                }
            }
            .store(in: &cancellables)
    }
}

struct CommunityView: View {
    @State private var community: Community
    @ObservedObject private var userSuggestionViewModel: UserLocalSuggestionViewModel
    @State private var isInviteViewPresented = false
    
    init(community: Community) {
        _userSuggestionViewModel = ObservedObject(wrappedValue: .init(data: community.members))
        _community = State(wrappedValue: community)
    }
    
    var body: some View {
        VStack {
            TextField("Suche nach einem Mitglied", text: $userSuggestionViewModel.userFilter)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Spacer()
            List(userSuggestionViewModel.filtered, id: \.0) { (member, position) in
                LeaderBoardListEntry(member: member, position: position)
            }
            .listStyle(.plain)
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
