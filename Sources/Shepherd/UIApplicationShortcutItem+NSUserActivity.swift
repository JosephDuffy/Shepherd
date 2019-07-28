#if os(iOS)
import UIKit

@available(iOS 9.0, *)
extension UIApplicationShortcutItem {

    private static let userActivityDataUserInfoKey = "userActivityData"

    /// A user activity that has been encoded in to the shortcut item's user info. For this property to be non-nil
    /// the shortcut item must have been created via `init(userActivity:localizedTitle:localizedSubtitle:icon:)`.
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
    @available(iOS 11.0, *)
    public convenience init(
        userActivity: NSUserActivity & NSSecureCoding,
        localizedTitle: String,
        localizedSubtitle: String?,
        icon: UIApplicationShortcutIcon?,
        userInfo: [String: NSSecureCoding]? = nil
    ) throws {
        let archivedData = try NSKeyedArchiver.archivedData(
            withRootObject: userActivity,
            requiringSecureCoding: true
        )

        self.init(
            userActivityArchivedData: archivedData,
            type: userActivity.activityType,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            icon: icon,
            userInfo: userInfo
        )
    }

    /// Create a shortcut item that encodes the provided user activity data in to the `userInfo` dictionary. This data
    /// should have been created by archiving an `NSUserActivity` as the root object of an `NSKeyedArchiver`.
    ///
    /// - See: `init(type:localizedTitle:localizedSubtitle:icon:userInfo:)`
    ///
    /// - Parameter archivedData: The archived data created by `NSKeyedArchiver`
    /// - Parameter type: The type of the user activity
    /// - Parameter localizedTitle: The required, user-visible title of the Home screen quick action.
    /// - Parameter localizedSubtitle: The optional, user-visible subtitle of the Home screen quick action.
    /// - Parameter icon: The optional icon for the Home screen quick action.
    /// - Parameter userInfo: App-defined information about the Home screen quick action, to be used by your app to
    ///                       implement the action.
    public convenience init(
        userActivityArchivedData archivedData: Data,
        type: String,
        localizedTitle: String,
        localizedSubtitle: String?,
        icon: UIApplicationShortcutIcon?,
        userInfo: [String: NSSecureCoding]? = nil
    ) {
        var userInfo = userInfo ?? [:]
        userInfo[UIApplicationShortcutItem.userActivityDataUserInfoKey] = archivedData as NSData

        self.init(
            type: type,
            localizedTitle: localizedTitle,
            localizedSubtitle: localizedSubtitle,
            icon: icon,
            userInfo: userInfo
        )
    }

}

#endif
