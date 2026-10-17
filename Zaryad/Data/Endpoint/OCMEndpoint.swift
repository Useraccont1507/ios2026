//
//  OCMEndpoint.swift
//  Zaryad
//
//  Created by Illia Verezei on 17.10.2026.
//

import Foundation

struct OCMEndpoint {
    private init() {}

    static func poi(near coordinate: Coordinate, radius: Double, maxResults: Int = 100) -> Endpoint {
        endpoint(path: "poi")
            .parameter("latitude", coordinate.latitude)
            .parameter("longitude", coordinate.longitude)
            .parameter("distance", radius)
            .parameter("distanceunit", "km")
            .parameter("maxresults", maxResults)
            .parameter("verbose", false)
            .parameter("includecomments", true)
    }

    private static func endpoint(path: String, method: HTTPMethod = .get) -> Endpoint {
        Endpoint(path: path, method: method)
            .parameter("output", "json")
            .header("X-API-Key", OCMConfig.apiKey)
    }
}
