//
//  NetworkError.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Розрізняє транспортні, HTTP- та decoding-помилки (NFR-3).
enum NetworkError: Error {
    case invalidURL
    case encoding(Error)
    case transport(URLError)
    case invalidResponse
    case http(RawResponse)
    case emptyData
    case decoding(Error)
}

extension NetworkError {
    var isCancelled: Bool {
        if case .transport(let error) = self { return error.code == .cancelled }
        return false
    }

    var toastMessage: String {
        switch self {
        case .transport(let error):
            switch error.code {
            case .notConnectedToInternet, .dataNotAllowed, .networkConnectionLost:
                "Немає з'єднання з інтернетом"
            case .timedOut:
                "Сервер не відповідає. Спробуйте пізніше"
            case .secureConnectionFailed, .serverCertificateUntrusted:
                "Не вдалося встановити захищене з'єднання"
            default:
                Self.somethingWentWrong
            }
        case .http(let response):
            switch response.statusCode {
            case 401: "Сесія завершилась. Увійдіть знову"
            case 403: "Немає доступу"
            case 404: "Дані не знайдено"
            case 429: "Забагато запитів. Спробуйте за хвилину"
            case 500...: "Сервер тимчасово недоступний"
            default: Self.somethingWentWrong
            }
        case .invalidURL, .encoding, .invalidResponse, .emptyData, .decoding:
            Self.somethingWentWrong
        }
    }

    private static let somethingWentWrong = "Щось пішло не так. Спробуйте ще раз"
}
