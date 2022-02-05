public extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, using comparator: (T, T) -> Bool = (<)) -> [Element] {
    sorted(by: { a, b in
      comparator(a[keyPath: keyPath], b[keyPath: keyPath])
    })
  }
}

public extension Sequence where Element: Hashable {
  func unique() -> [Element] {
    var s = Set<Element>()
    return filter { s.insert($0).inserted }
  }
}

public extension Sequence where Element: Identifiable {
  func keyedDictionary() -> [Element.ID: Element] {
    reduce(into: [:]) { d, o in d[o.id] = o }
  }
}
