extension ActivityHandler {

    /**
     A sequence that contains each of the ancestors of this activity handler, in order, starting with the immediate
     parent.
     */
    public var ancestors: Ancestors {
        return Ancestors(activityHandler: self)
    }

    /**
     A sequence of the ancestors of an activity handlers, in order, starting with the immediate parent.
     */
    public struct Ancestors: Sequence {

        private let activityHandler: ActivityHandler

        /**
         Create an anchestory sequence, starting at the provided activity handler.

         - Parameter activityHandler: The activity handler to start at.
         */
        public init(activityHandler: ActivityHandler) {
            self.activityHandler = activityHandler
        }

        /**
         Returns an iterator over the anchestors of the activity handler.

         - Returns: An iterator over the anchestors of the activity handler.
         */
        public func makeIterator() -> AncestorsIterator {
            return Iterator(activityHandler: activityHandler)
        }

    }

    /**
     An iterator that can iterate over the ancestors of an activity handler.
     */
    public struct AncestorsIterator: IteratorProtocol {

        private var current: ActivityHandler

        /**
         Create an anchestory iterator, starting at the provided activity handler.

         - Parameter activityHandler: The activity handler to start at.
         */
        public init(activityHandler: ActivityHandler) {
            current = activityHandler
        }

        /**
         Return the next anchestor in the sequence of iterators.

         - Returns: The next anchestor in the sequence of iterators.
         */
        public mutating func next() -> ActivityHandlerAggregate? {
            guard let parent = current.parent else { return nil }
            current = parent
            return parent
        }

    }

}
