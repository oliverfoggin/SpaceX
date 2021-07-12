//
//  FIlterState.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 11/07/2021.
//

import Foundation
import ComposableArchitecture

struct FilterState: Equatable {
    
    enum Sort {
        case asc, desc
    }
    
    var sortMethod: Sort = .asc
}

extension FilterState {
    func sort<U, T: Comparable>(items: IdentifiedArrayOf<U>, by keypath: KeyPath<U, T>) -> [U] {
        switch self.sortMethod {
        case .asc:
            return items.sorted(by: keypath, using: <)
        case .desc:
            return items.sorted(by: keypath, using: >)
        }
    }
}

enum FilterAction {
    case selectSortMethod(method: FilterState.Sort)
}

struct FilterEnvironment {}

let filterReducer = Reducer<FilterState, FilterAction, FilterEnvironment> {
    state, action, _ in
    switch action {
    case let .selectSortMethod(method: method):
        state.sortMethod = method
        return .none
    }
}
