//
//  APIProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

protocol APIProtocol {
    var path: String { get }
    var method: HTTPMethod{ get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [HTTPHeader]? { get }
    func toRequest() throws -> URLRequest
}
