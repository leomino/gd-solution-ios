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
            
            switch communityModel.state {
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
        .onChange(of: communityModel.state) {
            if case .success(let joined) = communityModel.state {
                onJoinSuccess(joined)
                dismiss.callAsFunction()
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        JoinCommunityView(dataService: CommunityDataServiceMock()) { _ in
            
        }
        .navigationTitle("Gruppe beitreten")
    }
}
