//
//  URLRequest+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

extension URLRequest {
    mutating func addHeaders(headers: [HTTPHeader]?) {
        headers?.forEach { httpHeader in
            addValue(
                httpHeader.value,
                forHTTPHeaderField: httpHeader.name
            )
        }
    }
}
