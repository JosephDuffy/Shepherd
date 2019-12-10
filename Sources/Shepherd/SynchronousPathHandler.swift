/// A `PathHandler` that can handle paths synchronously
public protocol SynchronousPathHandler: PathHandler {

    /**
     Attempt to handle the provided path. The path can be any type, but the handler does not have to attempt to handle
     all path types.

     If the provided path cannot be handled the implementation must return `nil`. If the provided path has been handled the
     implementation return the path handler that handled the path.

     - Parameter path: The path to attempt to handle.
     - Returns: The handler that handled the path, or `nil` if the path was not handled.
     */
    func handle<Path>(path: Path) -> PathHandler?

}

extension SynchronousPathHandler {

    public func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?) {
        let handler = handle(path: path)
        completionHandler?(handler)
    }

}
