//
//  NewsEndpoints.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 14.08.21.
//

import Foundation

public enum NewsEndpoints {
    case everything(params: Parameters?)
    case topHeadlines(params: Parameters?)
}
extension NewsEndpoints: EndPointType {
    var parameters: [URLQueryItem]? {
        get {
            switch self {
            case .everything(let params):
                guard let params = params else { break}
               return params.map({URLQueryItem(name: $0.key, value: $0.value)})
            case .topHeadlines(let params):
                guard let params = params else {break }
                return params.map({URLQueryItem(name: $0.key, value: $0.value)})
            }
            return self.parameters
        }
        set {}
    }

    public var path: String {
        switch self {
        case .everything:
            return "everything"
        case .topHeadlines:
            return "top-headlines"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .everything, .topHeadlines:
           return HTTPMethod.get
        }
    }
}

