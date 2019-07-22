#if os(iOS)
import UIKit

@available(iOS 9.0, *)
extension UIApplicationShortcutItem {

    private static let userActivityDataUserInfoKey = "userActivityData"

    /// A user activity that has been encoded in to the shortcut item's user info. For this property to be non-nil
    /// the shortcut item must have been created via `init(userActivity:localizedTitle:localizedSubtitle:icon:)`
    public var userActivity: NSUserActivity? {
        guard let data = userInfo?[UIApplicationShortcutItem.userActivityDataUserInfoKey] as? NSData else { return nil }
        guard let userActivity = NSKeyedUnarchiver.unarchiveObject(with: data as Data) else { return nil }
        return userActivity as? NSUserActivity
    }

    /// Create a shortcut item that encodes the provided user activity in to the `userInfo` dictionary. The `type` of
    /// the shortcut item will be the `activityType` of the user activity. If an error is thrown when attempting to
    /// archive the user activity via `NSKeyedArchiver.archivedData(withRootObject:requiringSecureCoding:)` it will be
    /// thrown by this initialiser.
    ///
    /// - See: `init(type:localizedTitle:localizedSubtitle:icon:userInfo:)`
    ///
    /// - Parameter userActivty: A user activity that will be encoded in to the `userInfo` dictionary
    /// - Parameter localizedTitle: The required, user-visible title of the Home screen quick action.
    /// - Parameter localizedSubtitle: The optional, user-visible subtitle of the Home screen quick action.
    /// - Parameter icon: The optional icon for the Home screen quick action.
    /// - Parameter userInfo: App-defined information about the Home screen quick action, to be used by your app to
    ///                       implement the action.
    public convenience init(
        userActivity: NSUserActivity & NSSecureCoding,
        localizedTitle: String,
        localizedSubtitle: String?,
        icon: UIApplicationShortcutIcon?,
        userInfo: [String: NSSecureCoding]? = nil
    ) throws {
        let archiveData: NSData
        if #available(iOS 11.0, *) {
            archiveData = try NSKeyedArchiver.archivedData(
                withRootObject: userActivity,
                requiringSecureCoding: true
            ) as NSData
        } else {
            let mutableData = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: mutableData)
            archiver.requiresSecureCoding = true
            archiver.encode(userActivity, forKey: NSKeyedArchiveRootObjectKey)
            archiver.finishEncoding()
            archiveData = mutableData
        }

        var userInfo = userInfo ?? [:]
        userInfo[UIApplicationShortcutItem.userActivityDataUserInfoKey] = archiveData

        self.init(
            type: userActivity.activityType,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            icon: icon,
            userInfo: userInfo
        )
    }

}
#endif
