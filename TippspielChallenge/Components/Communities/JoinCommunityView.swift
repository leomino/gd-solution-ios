//
//  JoinCommunityView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//

import SwiftUI

struct JoinCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var communityModel: CommunityModel
    @ObservedObject var suggestionModel: CommunitySuggestionModel
    @State private var selectedCommunityId: UUID?
    let onJoinSuccess: (Community) -> Void
    
    init(communityModel: CommunityModel = .init(), suggestionModel: CommunitySuggestionModel = .init(), onJoinSuccess: @escaping (Community) -> Void) {
        self.onJoinSuccess = onJoinSuccess
        self.communityModel = communityModel
        self.suggestionModel = suggestionModel
    }
    
    var body: some View {
        VStack(spacing: 32) {
            TextField("Gruppe suchen", text: $suggestionModel.searchString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            Group {
                switch suggestionModel.state {
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
                default:
                    Color.clear
                }
            }
            .overlay {
                if case .loading = suggestionModel.state {
                    ProgressView()
                }
                
                if case .failure(let error) = suggestionModel.state {
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            switch communityModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
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
        .onChange(of: communityModel.state) {
            if case .success(let joined) = communityModel.state {
                onJoinSuccess(joined)
                dismiss.callAsFunction()
            }
        }
        .padding()
    }
}

#Preview("Idle") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .idle, dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .idle, dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}

#Preview("Suggestions Success") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .idle, dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .success([.mock, .mock, .mock]), dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}

#Preview("Suggestions Loading") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .idle, dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .loading, dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}

#Preview("Suggestions Error") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .idle, dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .failure(HTTPError.mock), dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}

#Preview("Join Loading") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .loading, dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .success([.mock, .mock, .mock]), dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}

#Preview("Join Error") {
    NavigationStack {
        JoinCommunityView(
            communityModel: .init(state: .failure(HTTPError.mock), dataService: CommunityDataServiceMock()),
            suggestionModel: .init(state: .success([.mock, .mock, .mock]), dataService: CommunityDataServiceMock())
        ) { _ in}
        .navigationTitle("Gruppe beitreten")
    }
}
