//
//  Publisher.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Foundation
import Combine

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
                    throw URLError(.badServerResponse, userInfo: ["code": httpResponse.statusCode])
                }
                return output.data
            }
    }
}

extension NSError {
    static var notFound = NSError(
        domain: "",
        code: 404,
        userInfo: [NSLocalizedDescriptionKey: "404 Not found."]
    )
}
