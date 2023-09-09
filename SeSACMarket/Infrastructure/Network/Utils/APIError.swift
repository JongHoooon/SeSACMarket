//
//  APIError.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

enum APIError: Error {
    case invalidURL
    case badStatusCode(statusCode: Int, message: String? = nil, errorCode: String? = nil)
    case decodingError
    case noData
    case unknown
}
