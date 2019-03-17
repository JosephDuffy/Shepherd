import Foundation

public protocol ActivityHandlerAggregate: ActivityHandler {

    var children: [ActivityHandler] { get }

    func add(child: ActivityHandler)

    @discardableResult
    func handle(activity: NSUserActivity, ignoring: ActivityHandler?) -> ActivityHandler?

}

extension ActivityHandlerAggregate {

    /**
     Attempts to handle the provided activity by traversing the tree of handler.

     - see: traverseTreeToHandle(activity:ignoring:)

     - parameter activity: The activity to be handled
     - returns: A bool indicating if a handler handled the activity
     */
    @discardableResult
    public func handle(activity: NSUserActivity) -> Bool {
        return traverseTreeToHandle(activity: activity, ignoring: nil) != nil
    }

    /**
     Attempts to handle the provided activty by traversing the tree of handler.

     - see: traverseTreeToHandle(activity:ignoring:)

     - parameter activity: The activity to be handled
     - returns: The handler that handled the activity, or `nil` if the activity went unhandled
     */
    @discardableResult
    public func handle(activity: NSUserActivity, ignoring: ActivityHandler?) -> ActivityHandler? {
        return traverseTreeToHandle(activity: activity, ignoring: ignoring)
    }

    /**
     This is a convenience function that aids with the traversal of a tree of activity handlers. It will
     first try to find a child handler that can handle the activity and fallback to the parent (when avialable)

     Children will be traversed in the reverse of the order they are added to allow children to "trap"
     activities from being further handled.

     If a child is an `ActivityHandlerAggregate` the current handler will passed to `ignore` to prevent
     circular checks

     If no children can handle the activity and this object is an `ActivityHandlerNode` the parent will
     be asked to handle the activity (unless the `ignoring` parameter is the parent).

     With a tree as follows:

           (A)
          /   \
        (B)   (C)
       / | \     \
     (D)(E)(F)   (G)

     If the current handler is (D) and (G) can handle the activity the handlers would be called in the
     following order:

     - D
     - B
     - E
     - F
     - A
     - C
     - G

     This would result in (G) being returned from this function

     - parameter activity: The activity to attempt to handle
     - parameter ignoring: A handler to be ignored when traversing the tree of handlers
     - returns: The handler that handled the activity, or `nil` if the activity went unhandled
     */
    @discardableResult
    public func traverseTreeToHandle(activity: NSUserActivity, ignoring: ActivityHandler?) -> ActivityHandler? {
        if let self = self as? StackableActivityHandlerAggregate {
            let stackedHandler: ActivityHandler?
            if let ignoring = ignoring {
                let split = self.stackedHandlers.split(maxSplits: 1, whereSeparator: { $0 !== ignoring }).first!
                stackedHandler = Array(split).last
            } else {
                stackedHandler = self.stackedHandlers.last
            }
            
            if let stackedHandler = stackedHandler {
                if let stackedHandler = stackedHandler as? ActivityHandlerAggregate {
                    if let handler = stackedHandler.handle(activity: activity, ignoring: self) {
                        return handler
                    }
                } else if stackedHandler.handle(activity: activity) {
                    return stackedHandler
                }
            }
        }
        
        if let self = self as? ActivityHandlerAggregate {
            for child in self.children.reversed() where child !== ignoring {
                if let child = child as? ActivityHandlerAggregate {
                    if let handler = child.handle(activity: activity, ignoring: self) {
                        return handler
                    }
                } else if child.handle(activity: activity) {
                    return child
                }
            }
        }
        
        if let self = self as? ActivityHandlerNode, self.parent !== ignoring {
            return self.parent.handle(activity: activity, ignoring: self)
        }
        
        return nil
    }

}
