//
//  AddCommunityView.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 28.05.24.
//

import SwiftUI

struct AddCommunityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    let tournament: Tournament
    @ObservedObject var viewModel: CommunityModel
    let onCreateSuccess: (Community) -> Void
    
    init(
        for tournament: Tournament,
        viewModel: CommunityModel = .init(),
        onCreateSuccess: @escaping (Community) -> Void
    ) {
        self.tournament = tournament
        self.onCreateSuccess = onCreateSuccess
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Image(tournament.name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .padding()
                .background(.secondary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: 300)
            TextField("Gemeinschaftsname", text: $name)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            Spacer()
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            default:
                EmptyView()
            }
            Button("Erstellen") {
                viewModel.createCommunity(
                    .init(id: UUID(), name: name, tournament: tournament)
                )
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
    NavigationStack {
        AddCommunityView(for: .mock, viewModel: .init(state: .success(.mock), dataService: CommunityDataServiceMock())) { _ in }
    }
}

#Preview("Loading") {
    NavigationStack {
        AddCommunityView(for: .mock, viewModel: .init(state: .loading, dataService: CommunityDataServiceMock())) { _ in }
    }
}

#Preview("Error") {
    NavigationStack {
        AddCommunityView(for: .mock, viewModel: .init(state: .failure(HTTPError.mock), dataService: CommunityDataServiceMock())) { _ in }
    }
}
