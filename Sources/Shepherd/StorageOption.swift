extension ActivityHandler {

    public enum StorageOption {
        case strongly
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
