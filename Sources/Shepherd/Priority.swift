/// The priority of a router within a router. Routers are queried in decending priority order.
public struct Priority: RawRepresentable, ExpressibleByIntegerLiteral, Hashable, Comparable {

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    /// A high priority. Equal to 1000.
    public static let high: Priority = 1000

    /// A medium priority. Equal to 500.
    public static let medium: Priority = 500

    /// A low priority. Equal to 100.
    public static let low: Priority = 100

    /// The priority of a parent router. Equal to 0.
    public static let parent: Priority = 0

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: Int) {
        rawValue = value
    }

}
