//
//  AddCommunityView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 28.05.24.
//

import SwiftUI

class CommunityViewModel: LoadingStateModel<Community> {
    let dataService: CommunityDataServiceProtocol
    
    init(state: LoadingState<Community> = .idle, dataService: CommunityDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    func createCommunity(_ community: Community) {
        requests.send(dataService.createCommunity(community: community))
    }
}


struct AddCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    let tournament: Tournament
    @ObservedObject var viewModel: CommunityViewModel
    let onCreateSuccess: (Community) -> Void
    
    init(
        for tournament: Tournament,
        dataService: CommunityDataServiceProtocol = CommunityDataService(),
        onCreateSuccess: @escaping (Community) -> Void
    ) {
        self.tournament = tournament
        self.onCreateSuccess = onCreateSuccess
        _viewModel = ObservedObject(wrappedValue: .init(dataService: dataService))
    }
    
    init(
        for tournament: Tournament,
        dataService: CommunityDataServiceProtocol = CommunityDataService(),
        state: LoadingState<Community>,
        onCreateSuccess: @escaping (Community) -> Void
    ) {
        self.tournament = tournament
        self.onCreateSuccess = onCreateSuccess
        _viewModel = ObservedObject(wrappedValue: .init(state: state, dataService: dataService))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(tournament.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding()
                .background(.secondary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            TextField("Gemeinschaftsname", text: $name)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            Spacer()
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
            default:
                EmptyView()
            }
            Button("Gemeinschaft erstellen") {
                viewModel.createCommunity(.init(id: UUID(), name: name, tournament: tournament, members: []))
            }
            .disabled(name.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .onChange(of: viewModel.state) {
            if case .success(let created) = viewModel.state {
                onCreateSuccess(created)
                dismiss.callAsFunction()
            }
        }
        .padding()
    }
}

#Preview("Idle") {
    AddCommunityView(for: .mock, dataService: CommunityDataService()) { _ in }
}

#Preview("Loading") {
    AddCommunityView(for: .mock, dataService: CommunityDataService(), state: .loading) { _ in }
}

#Preview("Error") {
    AddCommunityView(for: .mock, dataService: CommunityDataService(), state: .failure(NSError.notFound)) { _ in }
}
