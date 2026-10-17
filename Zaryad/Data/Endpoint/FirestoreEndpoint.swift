//
//  FirestoreEndpoint.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct FirestoreEndpoint {
    private init() {}

    static func baseURL(projectID: String) -> URL {
        URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents")!
    }

    static func favorites(uid: String, token: String) -> Endpoint {
        endpoint(path: favoritesPath(uid: uid), token: token)
            .parameter("pageSize", 300)
    }

    static func putFavorite(_ body: Data, stationId: Int, uid: String, token: String) -> Endpoint {
        endpoint(path: "\(favoritesPath(uid: uid))/\(stationId)", method: .patch, token: token)
            .body(body, contentType: .json)
    }

    static func deleteFavorite(stationId: Int, uid: String, token: String) -> Endpoint {
        endpoint(path: "\(favoritesPath(uid: uid))/\(stationId)", method: .delete, token: token)
    }

    private static func favoritesPath(uid: String) -> String {
        "users/\(uid)/favorites"
    }

    private static func endpoint(path: String, method: HTTPMethod = .get, token: String) -> Endpoint {
        Endpoint(path: path, method: method)
            .token(token)
    }
}
