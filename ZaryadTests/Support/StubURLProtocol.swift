//
//  StubURLProtocol.swift
//  ZaryadTests
//
//  Created by Illia Verezei on 18.10.2026.
//

import Foundation

final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    // MARK: - Types -
    typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    // MARK: - Registry -
    private static let lock = NSLock()
    nonisolated(unsafe) private static var handlers: [String: Handler] = [:]
    nonisolated(unsafe) private static var requests: [String: [URLRequest]] = [:]
    // MARK: - Interface -
    static func session(host: String, handler: @escaping Handler) -> URLSession {
        lock.withLock { handlers[host] = handler }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }
    static func recordedRequests(host: String) -> [URLRequest] {
        lock.withLock { requests[host] ?? [] }
    }
    // MARK: - URLProtocol -
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        let host = request.url?.host() ?? ""
        let handler = Self.lock.withLock { () -> Handler? in
            Self.requests[host, default: []].append(request.withBody())
            return Self.handlers[host]
        }
        do {
            guard let handler else { throw URLError(.unsupportedURL) }
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}

// MARK: - Helpers -
extension HTTPURLResponse {
    static func stub(_ url: URL?, status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url ?? URL(string: "https://stub")!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}

private extension URLRequest {
    func withBody() -> URLRequest {
        guard httpBody == nil, let stream = httpBodyStream else { return self }
        var copy = self
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: buffer.count)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        }
        copy.httpBody = data
        return copy
    }
}

func uniqueHost() -> String {
    "stub-\(UUID().uuidString.lowercased()).test"
}
