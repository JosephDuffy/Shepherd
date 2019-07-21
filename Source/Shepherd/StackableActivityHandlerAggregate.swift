import Foundation

/**
 An activity handler that supports stacking, allowing handlers to be pushed
 on to the stack.
 
 Stacked handlers take a higher priority than children when trying to handle
 an activity.
 */
public protocol StackableActivityHandlerAggregate: ActivityHandlerAggregate {
    
    var stackedHandlers: [ActivityHandler] { get }
    
    func push(activityHandler: ActivityHandler)
    
}
