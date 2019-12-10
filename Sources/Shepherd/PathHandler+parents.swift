extension PathHandler {

    /// The parents of the path handler, ordered from the closest to furthest.
    public var parents: [PathHandler] {
        return Array(ParentsSequence(pathHandler: self))
    }

}

private struct ParentsSequence: Sequence {

    private let pathHandler: PathHandler

    fileprivate init(pathHandler: PathHandler) {
        self.pathHandler = pathHandler
    }

    fileprivate func makeIterator() -> PathHandlerParentsIterator {
        return PathHandlerParentsIterator(pathHandler: pathHandler)
    }

}

private struct PathHandlerParentsIterator: IteratorProtocol {

    fileprivate typealias Element = PathHandler

    private var current: PathHandler

    fileprivate init(pathHandler: PathHandler) {
        current = pathHandler
    }

    fileprivate mutating func next() -> PathHandler? {
        guard let parent = current.parent else { return nil }
        current = parent
        return parent
    }

}
