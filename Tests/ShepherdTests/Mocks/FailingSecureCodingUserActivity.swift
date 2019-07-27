#if os(iOS)
import UIKit

@available(iOS 9.0, *)
public final class FailingSecureCodingUserActivity: NSUserActivity, NSSecureCoding {

    public enum EncodingError: Error {
        case testError
    }

    public static let supportsSecureCoding = true

    public var errorToFailWith: Error?

    public init(encodedProperty: String = "") {
        super.init(activityType: "failing-secure-coding")
    }

    public init?(coder aDecoder: NSCoder) {
        return nil
    }

    public func encode(with aCoder: NSCoder) {
        if let errorToFailWith = errorToFailWith {
            aCoder.failWithError(errorToFailWith)
        }
    }

}
#endif
