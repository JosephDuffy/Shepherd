extension ActivityHandler {

    /// A method of storing an object
    public enum StorageOption {

        /// Store the object with a strong reference
        case strongly

        /// Store the object with a weak reference
        case weakly

        internal func store<Object>(_ object: Object) -> ObjectStorage<Object> {
            switch self {
            case .strongly:
                return .strong(object)
            case .weakly:
                return .weak(Weak(object))
            }
        }
    }

}
