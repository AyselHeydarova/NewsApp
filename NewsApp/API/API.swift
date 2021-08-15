//
//  API.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 11.08.21.
//

import UIKit

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public typealias Parameters = [String: String?]

class NetworkRequest {
    var searchTerm: String = "Apple"

    func executeRequest(_ request: NewsEndpoints,
                        page: Int, completion: @escaping ((Result<NewsModel, Error>)-> Void)) {
        if let  request = URLRequest(with: request, baseURL: request.baseURL) {
            resumeDataTask(withRequest: request, completion: completion)
        }
    }

    private func resumeDataTask(withRequest request: URLRequest, completion: @escaping (Result<NewsModel, Error>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                let decodedData = try? decoder.decode(NewsModel.self, from: data)
                guard let data = decodedData else { return }
                completion(.success(data))
            }
        }
        dataTask.resume()
    }
}





