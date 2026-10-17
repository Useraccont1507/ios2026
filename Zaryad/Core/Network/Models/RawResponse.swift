//
//  RawResponse.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct RawResponse: Sendable {
    let statusCode: Int
    let headers: [String: String]
    /// `nil`, якщо сервер повернув порожнє тіло (наприклад, 204).
    let data: Data?

    var isSuccess: Bool { (200..<300).contains(statusCode) }
}

extension RawResponse {
    func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = .zaryad) throws -> T {
        guard let data else { throw NetworkError.emptyData }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}

extension JSONDecoder {
    /// Декодер для API застосунку: дати у форматі ISO 8601 (як в Open Charge Map).
    static var zaryad: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
