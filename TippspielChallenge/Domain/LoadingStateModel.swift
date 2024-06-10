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

class LoadingStateModel<T: Equatable>: ObservableObject {
    @Published public var state: LoadingState<T>
    public var requests = PassthroughSubject<AnyPublisher<T, Error>, Never>()
    public var cancellables = Set<AnyCancellable>()

    public init(state: LoadingState<T> = .idle) {
        self.state = state
        setupRequestPublisher()
    }

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
                self?.requests = PassthroughSubject<AnyPublisher<T, Error>, Never>()
                self?.setupRequestPublisher()
            } receiveValue: { [weak self] result in
                self?.state = .success(result)
            }
            .store(in: &cancellables)
    }
}

public enum LoadingStateNotEquatable<T> {
    case idle, loading, success(T), failure(Error)
}

class LoadingStateModelNE<T>: ObservableObject {
    @Published public var state: LoadingStateNotEquatable<T>
    public var requests = PassthroughSubject<AnyPublisher<T, Error>, Never>()
    public var cancellables = Set<AnyCancellable>()

    public init(state: LoadingStateNotEquatable<T>) {
        self.state = state
        setupRequestPublisher()
    }

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
                self?.requests = PassthroughSubject<AnyPublisher<T, Error>, Never>()
                self?.setupRequestPublisher()
            } receiveValue: { [weak self] result in
                self?.state = .success(result)
            }
            .store(in: &cancellables)
    }
}
