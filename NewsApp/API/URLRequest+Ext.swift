//
//  URLRequest+Ext.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 14.08.21.
//

import Foundation

extension URLRequest {
    init?(with endPointType: EndPointType, baseURL: URL) {
        guard let fullURL = endPointType.fullURL(baseURL: baseURL) else { return nil }

        self.init(url: fullURL)
        self.httpMethod = endPointType.method.rawValue

        for (key, value) in endPointType.headers {
            self.addValue(value, forHTTPHeaderField: key)
        }
    }
}
