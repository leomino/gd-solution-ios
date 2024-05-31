//
//  Matches.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 31.05.24.
//
import Supabase
import Foundation

class MatchesViewModel: LoadingStateModel<[Match]> {
    let dataService: MatchDataServiceProtocol
    
    init(dataService: MatchDataServiceProtocol = MatchDataService()) {
        self.dataService = dataService
        super.init(state: .idle)
    }
    
    init(state: LoadingState<[Match]>, dataService: MatchDataServiceProtocol) {
        self.dataService = dataService
        super.init(state: state)
    }
    
    @MainActor
    func listenToMatchResultUpdates() async {
        guard 
            let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
            let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"],
            let supabaseURL = URL(string: urlString)
        else {
            return
        }
        let supabaseClient = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        let myChannel = await supabaseClient.channel("match-result-changes")
        let changes = await myChannel.postgresChange(UpdateAction.self, schema: "public", table: "MatchResults")
        await myChannel.subscribe()
        
        for await change in changes {
            do {
                let newMatchResult = try change.decodeRecord(as: MatchResult.self, decoder: JSONCoder.decoder)
                if case .success(var matches) = state {
                    guard let correspondingMatchIndex = matches.firstIndex(where: { $0.id == newMatchResult.matchId }) else {
                        return
                    }
                    matches[correspondingMatchIndex].result = newMatchResult
                    state = .success(matches)
                }
            } catch {
                // show alert when appropriate (e.g. internet connectivity problems)
                print(error)
            }
        }
    }
    
    func fetchAllMatches() {
        requests.send(dataService.fetchAll())
    }
    
    func fetchNextMatches() {
        requests.send(dataService.fetchNext())
    }
    
    func upsertPredictionInStore(for matchId: Match.ID, with prediction: Prediction) {
        if case .success(var matches) = state {
            if let index = matches.firstIndex(where: { $0.id == matchId }) {
                matches[index].prediction = prediction
            }
            state = .success(matches)
        }
    }
}
