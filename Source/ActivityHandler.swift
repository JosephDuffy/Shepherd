import Foundation

public protocol ActivityHandler: class {

    @discardableResult
    func handle(activity: NSUserActivity) -> Bool

}
