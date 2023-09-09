
//  HTTPHeader.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

struct HTTPHeader {
    let name: String
    let value: String
    
    init(
        name: String,
        value: String
    ) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader {
    static let accept = HTTPHeader(
        name: "accept",
        value: "application/json"
    )
    static let clientID = HTTPHeader(
        name: "X-Naver-Client-Id",
        value: APIKey.clientID
    )
    static let clientSecret = HTTPHeader(
        name: "X-Naver-Client-Secret",
        value: APIKey.cilentSecret
    )
}
