//
//  FIlterState.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 11/07/2021.
//

import Foundation
import ComposableArchitecture

enum SuccessFilter: String, CaseIterable {
    case all = "All"
    case successful = "Success"
    case unsuccessful = "Failed"
}

struct FilterState: Equatable {
    var ascending: Bool = true
    var successFilter: SuccessFilter = .all
    var years: [String] = []
    var year: String = "All"
}

extension FilterState {
    static let yearFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    func sort<U, T: Comparable>(items: IdentifiedArrayOf<U>, by keypath: KeyPath<U, T>) -> [U] {
        items.sorted(by: keypath, using: self.ascending ? (<) : (>))
    }
}

enum FilterAction: Equatable {
    case binding(BindingAction<FilterState>)
}

struct FilterEnvironment {}

let filterReducer = Reducer<FilterState, FilterAction, FilterEnvironment> { _, _, _ in .none }
.binding(action: /FilterAction.binding)
