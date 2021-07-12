//
//  FilterView.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 11/07/2021.
//

import SwiftUI
import ComposableArchitecture

struct FilterView: View {
    let store: Store<FilterState, FilterAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                
            }
        }
    }
}
