import Foundation

/**
 An activity handler that can have child activity handlers. When handling an activity it will ask the children to handle
 the activity before asking the parent to handle it.
*/
open class ActivityHandlerAggregate: ActivityHandler {

    private var _children: [ObjectStorage<ActivityHandler>] = []

    /// The children that will be asked to handle activities.
    public var children: [ActivityHandler] {
        return _children.compactMap { $0.object }
    }

    /// Create an activity handler aggregate.
    public override init() {}

    /**
     Adds the activity handler to the array of children that will be queried when attempting to handle
     an activity. The `parent` of `child` will be set to this aggregate.

     - Parameter child: The child to add.
     - Parameter storageOption: How to store the object, weakly or strongly.
     */
    open func append(_ child: ActivityHandler, heldOnTo storageOption: StorageOption) {
        _children.append(storageOption.store(child))
        child.parent = self
    }

    /**
     Removes the activity handler from the array of children that will be queried when attempting to handle
     an activity. If the passed activity handler was a child of this activity handler the `parent` property will be set
     to `nil`.

     - Parameter child: The child to be removed.
     */
    open func remove(_ child: ActivityHandler) {
        let countBefore = _children.count
        _children.removeAll(where: { $0.object === child })

        let didRemove = countBefore != _children.count
        guard didRemove else { return }

        child.parent = nil
    }

    /**
     Attempts to handle the provided activity by asking children to handle the activity. If none
     of the children handle the activity the parent will also be asked to handle it.

     - Parameter activity: The activity to be handled.
     - Parameter ignoring: An optional activity handler that should be ignored. The only valid value is one of the
                           children, the parent, or `nil`.
     - Returns: The handler that handled the activity, or `nil` if the activity was not handled.
     */
    @discardableResult
    open override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        for child in self.children where child !== ignoring {
            if let handler = child.handle(activity: activity, ignoring: self) {
                return handler
            }
        }

        return super.handle(activity: activity, ignoring: ignoring)
    }

}
