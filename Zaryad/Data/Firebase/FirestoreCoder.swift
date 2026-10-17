//
//  FirestoreCoder.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

/// Конвертує звичайний JSON (`Codable`) у типізований формат Firestore REST
/// (`{"fields": {"rate": {"integerValue": "5"}, ...}}`) і назад.
enum FirestoreCoder {
    enum CoderError: Error {
        case unsupportedValue
        case invalidDocument
    }

    // MARK: - Encode
    static func documentBody<T: Encodable>(_ value: T) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(value))
        guard let object = json as? [String: Any] else { throw CoderError.unsupportedValue }
        return try JSONSerialization.data(withJSONObject: ["fields": try object.mapValues(firestoreValue)])
    }

    private static func firestoreValue(_ value: Any) throws -> [String: Any] {
        switch value {
        case is NSNull:
            return ["nullValue": NSNull()]
        case let number as NSNumber where CFGetTypeID(number) == CFBooleanGetTypeID():
            return ["booleanValue": number.boolValue]
        case let number as NSNumber:
            return isInteger(number) ? ["integerValue": number.stringValue] : ["doubleValue": number.doubleValue]
        case let string as String:
            return ["stringValue": string]
        case let array as [Any]:
            return ["arrayValue": ["values": try array.map(firestoreValue)]]
        case let object as [String: Any]:
            return ["mapValue": ["fields": try object.mapValues(firestoreValue)]]
        default:
            throw CoderError.unsupportedValue
        }
    }

    private static func isInteger(_ number: NSNumber) -> Bool {
        !["d", "f"].contains(String(cString: number.objCType))
    }

    // MARK: - Decode
    /// Декодує `documents` з відповіді `GET .../collection` (порожня колекція → `[]`).
    static func decodeDocuments<T: Decodable>(_ type: T.Type, from data: Data?) throws -> [T] {
        guard let data,
              let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let documents = root["documents"] as? [[String: Any]] else { return [] }
        return try documents.map { document in
            guard let fields = document["fields"] as? [String: Any] else { throw CoderError.invalidDocument }
            let json = try JSONSerialization.data(withJSONObject: fields.mapValues(plainValue))
            return try JSONDecoder.zaryad.decode(type, from: json)
        }
    }

    private static func plainValue(_ value: Any) -> Any {
        guard let typed = value as? [String: Any], let (kind, payload) = typed.first else { return NSNull() }
        switch kind {
        case "integerValue":
            return Int(payload as? String ?? "") ?? payload
        case "arrayValue":
            return ((payload as? [String: Any])?["values"] as? [Any] ?? []).map(plainValue)
        case "mapValue":
            return ((payload as? [String: Any])?["fields"] as? [String: Any] ?? [:]).mapValues(plainValue)
        case "nullValue":
            return NSNull()
        default:
            return payload
        }
    }
}
