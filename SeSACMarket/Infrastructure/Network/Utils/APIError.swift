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
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case let .badStatusCode(statusCode, message, errorCode):
            if let message {
                return message + "\n\(errorCode ?? "")"
            } else {
                return "bad status Code\n\(statusCode)"
            }
        case .decodingError:
            return "디코딩 에러입니다."
        case .noData:
            return "데이터가 없습니다."
        case .unknown:
            return "알 수 없는 오류입니다."
        }
    }
}
