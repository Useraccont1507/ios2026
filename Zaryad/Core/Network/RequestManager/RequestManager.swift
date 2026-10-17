//
//  RequestManager.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

final class RequestManager: PRequestManager {
    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()

    private let baseURL: URL
    private let session: URLSession
    private let toastPresenter: PToastPresenter

    init(
        baseURL: URL,
        session: URLSession = RequestManager.session,
        toastPresenter: PToastPresenter = Toast.shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.toastPresenter = toastPresenter
    }

    func sendData(_ endpoint: PEndpoint) async throws -> RawResponse {
        do {
            let request = try endpoint.makeRequest(baseURL: baseURL)
            let (data, urlResponse) = try await session.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            let response = RawResponse(
                statusCode: httpResponse.statusCode,
                headers: Self.headers(of: httpResponse),
                data: data.isEmpty ? nil : data
            )
            guard response.isSuccess else { throw NetworkError.http(response) }
            return response
        } catch {
            let networkError = Self.networkError(from: error)
            if endpoint.isNeedShowToast && !networkError.isCancelled {
                toastPresenter.show(networkError.toastMessage)
            }
            throw networkError
        }
    }

    private static func networkError(from error: Error) -> NetworkError {
        switch error {
        case let error as NetworkError: error
        case let error as URLError: .transport(error)
        case is CancellationError: .transport(URLError(.cancelled))
        default: .transport(URLError(.unknown))
        }
    }

    private static func headers(of response: HTTPURLResponse) -> [String: String] {
        response.allHeaderFields.reduce(into: [:]) { result, header in
            guard let key = header.key as? String else { return }
            result[key] = "\(header.value)"
        }
    }
}
