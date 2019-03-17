import Foundation

public protocol ActivityHandlerAggregate: ActivityHandler {

    var children: [ActivityHandler] { get }

    func add(child: ActivityHandler)

    @discardableResult
    func handle(activity: NSUserActivity, ignoring: ActivityHandler?) -> ActivityHandler?

}

extension ActivityHandlerAggregate {

    /**
     Attempts to handle the provided activity by traversing the tree of the handler

     - see: traverseTree(toHandle:ignoring:)

     - parameter activity: The activity to be handled
     - returns: The handler that handled the activity, or `nil` if the activity went unhandled
     */
    @discardableResult
    public func handle(activity: NSUserActivity, ignoring: ActivityHandler?) -> ActivityHandler? {
        return traverseTree(toHandle: activity, ignoring: ignoring)
    }

}
