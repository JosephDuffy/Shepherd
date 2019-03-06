import Foundation

public protocol ActivityHandlerNode: ActivityHandler {

    // Should be held on to weakly
    var parent: ActivityHandlerAggregate { get }

}
