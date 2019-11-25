extension Sequence {
    internal func stableSorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        // swiftlint:disable identifier_name
        return try enumerated().sorted { a, b in
            try areInIncreasingOrder(a.element, b.element) ||
                (a.offset < b.offset && !areInIncreasingOrder(b.element, a.element))
        }
        .map { $0.element }
    }
}
