//
//  PRequestManager.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

protocol PRequestManager {
    /// Кидає `NetworkError`; при помилці показує тост, якщо `endpoint.isNeedShowToast`.
    func sendData(_ endpoint: PEndpoint) async throws -> RawResponse
}
