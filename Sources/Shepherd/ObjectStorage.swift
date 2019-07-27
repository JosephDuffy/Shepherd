internal enum ObjectStorage<Object: AnyObject> {
    case strong(Object)
    case weak(Weak<Object>)

    internal var object: Object? {
        switch self {
        case .strong(let object):
            return object
        case .weak(let wrapper):
            return wrapper.object
        }
    }
}

internal final class Weak<Object: AnyObject> {

    internal private(set) weak var object: Object?

    internal init(_ object: Object) {
        self.object = object
    }

}
