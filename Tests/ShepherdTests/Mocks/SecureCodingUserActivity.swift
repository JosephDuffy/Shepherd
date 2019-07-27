#if os(iOS)
import UIKit

@available(iOS 9.0, *)
public final class SecureCodingUserActivity: NSUserActivity, NSSecureCoding {

    public static let supportsSecureCoding = true

    public let encodedProperty: String

    public init(encodedProperty: String = "") {
        self.encodedProperty = encodedProperty

        super.init(activityType: "secure-coding")
    }

    public init?(coder aDecoder: NSCoder) {
        guard let encodedProperty = aDecoder.decodeObject(forKey: "encodedProperty") as? String else { return nil }

        self.encodedProperty = encodedProperty

        super.init(activityType: "secure-coding")
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SecureCodingUserActivity else { return false }
        guard object.encodedProperty == encodedProperty else { return false }
        return true
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(encodedProperty, forKey: "encodedProperty")
    }

}
#endif
