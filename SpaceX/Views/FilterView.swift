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
            Form {
                Section(header: Text("Sort by date:")) {
                    Toggle(isOn: viewStore.binding(keyPath: \.ascending, send: FilterAction.binding)) {
                        Text("Ascending")
                    }
                }
                
                Section(header: Text("Filter by success:")) {
                    Picker(
                        "",
                        selection: viewStore.binding(keyPath: \FilterState.successFilter, send: FilterAction.binding)) {
                        ForEach(SuccessFilter.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Filter by year:")) {
                    Picker(
                        "",
                        selection: viewStore.binding(keyPath: \FilterState.year, send: FilterAction.binding)) {
                        ForEach(viewStore.years, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(InlinePickerStyle())
                }
            }
        }
    }
}
