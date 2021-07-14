//
//  Collection.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 11/07/2021.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = (<)) -> [Element] {
        sorted(by: { a, b in
            return comparator(a[keyPath: keyPath], b[keyPath: keyPath])
        })
    }
}

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var s = Set<Element>()
        return filter { s.insert($0).inserted }
    }
}
