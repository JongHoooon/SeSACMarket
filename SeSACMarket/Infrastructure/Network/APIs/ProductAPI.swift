//
//  ProductAPI.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

enum ProductAPI: APIProtocol {
    case fetchQuery(productQuery: ProductQuery, start: Int, display: Int)
    
    var path: String {
        let baseURL = Endpoint.baseURL
        switch self {
        case  .fetchQuery:          return baseURL
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchQuery:           return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .fetchQuery(productQuery, start, display):
                return [
                    URLQueryItem(name: "query", value: productQuery.query),
                    URLQueryItem(name: "sort", value: sortValueQuery(productQuery.sortValue)),
                    URLQueryItem(name: "start", value: "\(start)"),
                    URLQueryItem(name: "display", value: "\(display)")
                ]
        }
    }

    var headers: [HTTPHeader]? {
        switch self {
        case .fetchQuery:
            return [
                .accept,
                .clientID,
                .clientSecret
            ]
        }
    }

    func toRequest() throws -> URLRequest {
        guard var urlComponets = URLComponents(string: path)
        else {
            throw APIError.invalidURL
        }
        if let queryItems {
            urlComponets.queryItems = queryItems
        }
        guard let url = urlComponets.url
        else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addHeaders(headers: headers)
        return request
    }
}

private extension ProductAPI {
    func sortValueQuery(_ sortValue: Product.SortValue) -> String {
        switch sortValue {
        case .similarity:               return "sim"
        case .date:                     return "date"
        case .priceDescending:          return "dsc"
        case .priceAscending:           return "asc"
        }
    }
}

