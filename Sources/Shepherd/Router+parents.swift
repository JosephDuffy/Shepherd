extension Router {

    /// The parents of the router, ordered from the closest to furthest.
    public var parents: [Router] {
        return Array(ParentsSequence(router: self))
    }

}

private struct ParentsSequence: Sequence {

    private let router: Router

    fileprivate init(router: Router) {
        self.router = router
    }

    fileprivate func makeIterator() -> PathHandlerParentsIterator {
        return PathHandlerParentsIterator(router: router)
    }

}

private struct PathHandlerParentsIterator: IteratorProtocol {

    fileprivate typealias Element = Router

    private var current: Router

    fileprivate init(router: Router) {
        current = router
    }

    fileprivate mutating func next() -> Router? {
        guard let parent = current.parent else { return nil }
        current = parent
        return parent
    }

}
