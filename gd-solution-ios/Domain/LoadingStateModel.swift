//
//  LoadingStateModel.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Combine
import SwiftUI

public enum LoadingState<T: Equatable>: Equatable {
    case idle, loading, success(T), failure(Error)
    
    public static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case (.failure(let lhsError as NSError), .failure(let rhsError as NSError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

/// Manages the loading state for any `viewModel` depending on remote object fetching.
open class LoadingStateModel<T: Equatable>: ObservableObject {
    @Published public var state: LoadingState<T>
    public var requests = PassthroughSubject<AnyPublisher<T, Error>, Never>()
    public var cancellables = Set<AnyCancellable>()

    /// Initializes by synchronizing the loading state with an initial ongoing initial request.
    public init(publisher: AnyPublisher<T, Error>) {
        state = .idle
        setupRequestPublisher()
        requests.send(publisher)
    }

    /// Initializes by setting the state to a predefined value.
    /// If no value provided, the state is set to idle as there is nothing else to do.
    public init(state: LoadingState<T>) {
        self.state = state
        setupRequestPublisher()
    }

    /// Sets up the observation of all incoming requests.
    private func setupRequestPublisher() {
        requests
            .flatMap {
                self.state = .loading
                return $0
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error)
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] result in
                self?.state = .success(result)
            }
            .store(in: &cancellables)
    }
}
