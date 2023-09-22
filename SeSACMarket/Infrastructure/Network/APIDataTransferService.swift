//
//  APIDataTransferService.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import Foundation

protocol APIDataTransferService {}
extension APIDataTransferService {
    func callRequest<D: Decodable, A: APIProtocol>(
            of: D.Type,
            api: A
        ) async throws -> D {
            do {
                let request = try api.toRequest()
                let (data, response) = try await URLSession.shared.data(for: request)
                logResponse(
                    request: request,
                    response: response,
                    data: data,
                    api: api
                )
                try filterStatusCode(response: response, data: data)
                let value = try decodingData(decodable: of, data: data)
                return value
            } catch {
                throw error
            }
        }
    
    private func filterStatusCode(
        response: URLResponse,
        data: Data,
        range: Range<Int> = 200..<300
    ) throws {
        guard let response = response as? HTTPURLResponse
        else {
            throw APIError.unknown
        }
        let statusCode = response.statusCode
        
        guard range ~= statusCode else {
            let errorResponse = try? JSONDecoder().decode(ErrorRseponse.self, from: data)
            throw APIError.badStatusCode(
                statusCode: statusCode,
                message: errorResponse?.errorMessage,
                errorCode: errorResponse?.errorCode
            )
        }
    }
    
    private func decodingData<D: Decodable>(
        decodable: D.Type,
        data: Data
    ) throws -> D {
        do {
            let value = try JSONDecoder().decode(
                decodable,
                from: data
            )
            return value
        } catch {
            throw APIError.decodingError
        }
    }
    
    private func logResponse(
        request: URLRequest,
        response: URLResponse,
        data: Data,
        api: APIProtocol
    ) {
        guard let response = response as? HTTPURLResponse else { return }
        let url = request.url?.absoluteString ?? ""
        let method = request.httpMethod ?? ""
        let statusCode = response.statusCode
        let header = request.allHTTPHeaderFields ?? [:]
        let headerStr: String = header.map {
            return "\n" + #"""# + "\($0.key)" + #"""# + ": " + #"""# + "\($0.value)" + #"""#
        }.joined()
        let body = String(bytes: request.httpBody ?? Data(), encoding:
                            String.Encoding.utf8) ?? ""
        let responseData = String(bytes: data, encoding: String.Encoding.utf8) ?? ""
        
        let log = """
            ----------------------- ✨ API Log ✨ -----------------------
            [Did Receive - Success]
            ✨ API: \(api)
            ✨ URL: \(url)
            ✨ METHOD: \(method)
            ✨ HEADER: \(headerStr)
            ✨ BODY: \(body)
            ✨ RESPONSE: \(responseData)
            ✨ STATUS CODE: \(statusCode)
            ----------------------- ✨ End Log ✨ -----------------------
            """
        print(log)
        
    }
    
}
struct ErrorRseponse: Decodable {
    let errorMessage: String
    let errorCode: String
}
