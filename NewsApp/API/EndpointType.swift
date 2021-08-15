//
//  EndpointType.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 14.08.21.
//

import Foundation

private let apiKey = "f12b9883d58d4729adddc8f23738150b"

protocol EndPointType {
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [URLQueryItem]? { get set}
    var defaultParams: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension EndPointType {
    var baseURL: URL {
        guard let url = URL(string: "https://newsapi.org/v2/")
        else { fatalError("baseURL could not be configured.") }
        return url
    }
    var method: HTTPMethod { return .get }
    var parameters: [URLQueryItem]? { return [] }
    var defaultParams: [URLQueryItem]
    { return
            [URLQueryItem(name: .apiKey, value: apiKey),
             URLQueryItem(name: .pageSize, value: "\(20)"),
            ]}
    var headers: [String: String] { return [:] }
    var body: Data? { return nil }

    mutating func appendParameter(name: String, value: String) {
        parameters?.append(URLQueryItem(name: name, value: value))

    }
    func fullURL(baseURL: URL) -> URL? {
        guard let url = URL(string: path, relativeTo: baseURL),
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        if method == .get {
            guard let params = parameters else {
                urlComponents.queryItems = defaultParams
                return urlComponents.url
            }
            urlComponents.queryItems = defaultParams + params
        }
        return urlComponents.url
    }
}
