//
//  SortCollectionViewCellReactor.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/26/23.
//

import Foundation

import ReactorKit

final class SortCollectionViewCellReactor: Reactor {
    typealias Action = NoAction
    
    struct State {
        var isSelected: Bool = false
    }
    
    var initialState = State()
    
    
}
