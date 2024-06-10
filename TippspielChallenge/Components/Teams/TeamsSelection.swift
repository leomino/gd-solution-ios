//
//  TeamsSelection.swift
//  TippspielChallenge
//
//  Created by Leonardo Palomino on 16.06.24.
//

import SwiftUI

struct TeamSelection: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: TeamsModel
    @Binding var selection: Team?
    @State private var filterString = ""
    
    init(selection: Binding<Team?>, viewModel: TeamsModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selection = selection
    }
    
    var filteredTeams: [Team] {
        if case .success(let teams) = viewModel.state {
            if filterString.isEmpty {
                return teams
            } else {
                return teams.filter { $0.name.contains(filterString) }
            }
        }
        return []
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .success:
                List(filteredTeams) { team in
                    Button {
                        selection = team
                        dismiss.callAsFunction()
                    } label: {
                        HStack {
                            Circle()
                                .frame(width: 25)
                                .overlay {
                                    Image(team.nameShort)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipShape(Circle())
                            Text(team.name)
                        }
                    }
                }
                .searchable(text: $filterString)
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.fetchTeams()
            }
        }
    }
}

#Preview("Success") {
    TeamSelection(selection: .constant(.mock), viewModel: .init(state: .success([.mock])))
}

#Preview("Loading") {
    TeamSelection(selection: .constant(.mock), viewModel: .init(state: .loading))
}

#Preview("Error") {
    TeamSelection(selection: .constant(.mock), viewModel: .init(state: .failure(HTTPError.mock)))
}
