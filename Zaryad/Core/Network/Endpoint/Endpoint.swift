//
//  Endpoint.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Запит, що збирається ланцюжком:
/// ```swift
/// Endpoint(path: "poi", method: .get)
///     .parameter("latitude", 50.45)
///     .parameter("maxresults", 50)
///     .token(session.token)
/// ```
struct Endpoint: PEndpoint {
    let path: String
    let method: HTTPMethod
    private(set) var headers: [String: String] = [:]
    private(set) var queryItems: [URLQueryItem] = []
    private(set) var isNeedShowToast = true
    private var body: Body?

    init(path: String, method: HTTPMethod = .get) {
        self.path = path
        self.method = method
    }

    func makeBody() throws -> Data? {
        switch body {
        case .none:
            return nil
        case .data(let data):
            return data
        case .encodable(let value, let encoder):
            do {
                return try encoder.encode(value)
            } catch {
                throw NetworkError.encoding(error)
            }
        }
    }
}

// MARK: - Builder
extension Endpoint {
    func body<T: Encodable & Sendable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> Endpoint {
        var copy = self
        copy.body = .encodable(value, encoder)
        return copy.contentType(.json)
    }
    func body(_ data: Data, contentType: ContentType) -> Endpoint {
        var copy = self
        copy.body = .data(data)
        return copy.contentType(contentType)
    }
    /// `nil` пропускається — зручно для необов'язкових фільтрів.
    func parameter(_ name: String, _ value: CustomStringConvertible?) -> Endpoint {
        guard let value else { return self }
        var copy = self
        copy.queryItems.append(URLQueryItem(name: name, value: value.description))
        return copy
    }
    func parameters(_ parameters: [String: CustomStringConvertible?]) -> Endpoint {
        parameters
            .sorted { $0.key < $1.key }
            .reduce(self) { $0.parameter($1.key, $1.value) }
    }
    func header(_ name: String, _ value: String?) -> Endpoint {
        var copy = self
        copy.headers[name] = value
        return copy
    }
    func contentType(_ contentType: ContentType) -> Endpoint {
        header("Content-Type", contentType.value)
    }
    func token(_ token: String?) -> Endpoint {
        header("Authorization", token.map { "Bearer \($0)" })
    }
    func showToastOnError(_ isNeedShowToast: Bool) -> Endpoint {
        var copy = self
        copy.isNeedShowToast = isNeedShowToast
        return copy
    }
}

// MARK: - Body
extension Endpoint {
    private enum Body: @unchecked Sendable {
        case data(Data)
        case encodable(any Encodable, JSONEncoder)
    }
}
