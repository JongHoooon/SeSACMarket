//
//  SortEnum.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

enum SortEnum: CaseIterable {
case similarity
case date
case priceDescending
case priceAscending
}

extension SortEnum {
    var parameter: String {
        switch self {
        case .similarity:               return "sim"
        case .date:                     return "date"
        case .priceDescending:          return "dsc"
        case .priceAscending:           return "asc"
        }
    }
    
    var title: String {
        switch self {
        case .similarity:               return "정확도"
        case .date:                     return "날짜순"
        case .priceDescending:          return "가격높은순"
        case .priceAscending:           return "가격낮은순"
        }
    }
}
