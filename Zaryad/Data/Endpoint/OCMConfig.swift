//
//  OCMConfig.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

enum OCMConfig {
    static let baseURL = URL(string: "https://api.openchargemap.io/v3")!

    /// `OCM_API_KEY` з `Config/Secrets.xcconfig` → Info.plist (`OCMAPIKey`).
    static var apiKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OCMAPIKey") as? String,
              !key.isEmpty else { return nil }
        return key
    }
}
