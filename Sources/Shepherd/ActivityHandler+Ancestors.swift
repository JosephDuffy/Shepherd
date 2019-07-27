extension ActivityHandler {

    /**
     A sequence that contains each of the ancestors of this activity
     handler, in order, starting with the immediate parent.
     */
    public var ancestors: Ancestors {
        return Ancestors(activityHandler: self)
    }

    public struct Ancestors: Sequence {

        private let activityHandler: ActivityHandler

        public init(activityHandler: ActivityHandler) {
            self.activityHandler = activityHandler
        }

        public func makeIterator() -> AncestorsIterator {
            return Iterator(activityHandler: activityHandler)
        }

    }

    public struct AncestorsIterator: IteratorProtocol {

        private var current: ActivityHandler

        public init(activityHandler: ActivityHandler) {
            current = activityHandler
        }

        public mutating func next() -> ActivityHandlerAggregate? {
            guard let parent = current.parent else { return nil }
            current = parent
            return parent
        }

    }

}
