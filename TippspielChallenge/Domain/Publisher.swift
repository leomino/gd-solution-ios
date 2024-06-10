//
//  Publisher.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Foundation
import Combine

struct HTTPError: LocalizedError, Codable {
    let errorDescription: String?
}

extension HTTPError {
    static var mock: Self = .init(errorDescription: "An error occurred.")
}

extension Publisher {
    /// Validates a URL response on positive response status codes, throws errors on negative codes.
    func validateResponse() -> Publishers.TryMap<Self, Data> where Self.Output == (data: Data, response: URLResponse) {
        return self
            .tryMap { output in
                guard
                    let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                guard (200 ... 299) ~= httpResponse.statusCode else {
                    let error = try? JSONDecoder().decode(HTTPError.self, from: output.data)
                    throw error ?? URLError(.badServerResponse, userInfo: ["code": httpResponse.statusCode])
                }
                return output.data
            }
    }
}
