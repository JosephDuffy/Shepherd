/// The priority of a route handler in a collection of router. Route handlers are
/// handled in decending priority order.
public enum Priority: Int, Hashable, Comparable, RawRepresentable {

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    /// A high priority. Equal to 1000.
    case high = 1000

    /// A medium priority. Equal to 500.
    case medium = 500

    /// A low priority. Equal to 100.
    case low = 100

    /// The priority of a parent router. Equal to 0.
    case parent = 0

}
