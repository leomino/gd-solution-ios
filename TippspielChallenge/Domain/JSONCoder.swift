//
//  JSONCoder.swift
//  gd-solution-ios
//
//  Created by Leonardo Palomino on 12.05.24.
//

import Foundation

public class JSONCoder {
    public static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            formatter.formatOptions = [.withFullDate, .withFullTime]
            if let date = formatter.date(from: dateString.replacing(" ", with: "T")) {
                return date
            }
            
            formatter.formatOptions = [.withFullDate]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }()

    public static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
