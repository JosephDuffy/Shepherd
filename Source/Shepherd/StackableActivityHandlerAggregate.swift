import Foundation

/**
 An activity handler that supports stacking, allowing handlers to be pushed
 on to the stack.
 
 Stacked handlers take a higher priority than children when trying to handle
 an activity.
 */
open class StackableActivityHandlerAggregate: ActivityHandlerAggregate {
    
    open private(set) var stackedHandler: ActivityHandler?
    
    open func push(stackedHandler: ActivityHandler) {
        self.stackedHandler = stackedHandler
        stackedHandler.parent = self
    }

    /**
     This is a convenience function that aids with the traversal of a tree of activity handlers. It will
     first try to find a child handler that can handle the activity and fallback to the parent (when available)

     Children will be traversed in the reverse of the order they are added to allow children to "trap"
     activities from being further handled.

     If a child is an `ActivityHandlerAggregate` the current handler will passed to `ignore` to prevent
     circular checks

     If no children can handle the activity and this object is an `ActivityHandlerNode` the parent will
     be asked to handle the activity (unless the `ignoring` parameter is the parent).

     With a tree as follows:

     ```
           (A)
          /   \
        (B)   (C)
       / | \     \
     (D)(E)(F)   (G)
     ```

     If the current handler is (D) and (G) can handle the activity the handlers would be called in the
     following order:

     - D
     - B
     - E
     - F
     - A
     - C
     - G

     This would result in (G) being returned

     - parameter activity: The activity to attempt to handle
     - parameter ignoring: A handler to be ignored when traversing the tree of handlers
     - returns: The handler that handled the activity, or `nil` if the activity went unhandled
     */
    @discardableResult
    open override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        if let stackedHandler = stackedHandler, stackedHandler !== ignoring {
            if let handler = stackedHandler.handle(activity: activity, ignoring: self) {
                return handler
            }
        }

        return super.handle(activity: activity, ignoring: ignoring)
    }
    
}
