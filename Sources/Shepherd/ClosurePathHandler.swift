internal final class ClosurePathHandler<Path>: PathHandler {
    
    internal typealias Handler = (_ route: Path, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    internal weak var parent: PathHandler?
    
    private let handler: Handler

    internal init(handler: @escaping Handler) {
        self.handler = handler
    }

    internal func handle<AnyPath>(path: AnyPath, completionHandler: ((PathHandler?) -> Void)?) {
        guard let route = path as? Path else {
            completionHandler?(nil)
            return
        }

        handler(route) { didHandle in
            completionHandler?(didHandle ? self : nil)
        }
    }

}

extension Router {

    /**
     A closure that can be queried when attempting to handle a path.

     - Parameter path: The path to attempt to handle.
     - Parameter completionHandler: A closure to be called when the path has been handled, or it is determined the path
                                    cannot be handled.
     */
    public typealias ClosurePathHandler<Path> = (_ path: Path, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    /**
     Add the provided closure to be a path handler.

     When the closure is called it should attempt to handle the path. If the path is handled the closure should be
     called with `true`, otherwise the closure should be called with `false`.

     - Parameter priority: The priority of the handler. Defaults to medium.
     - Parameter pathHandler: A closure that will be queried when handling a path of type `Path`.
     */
    @discardableResult
    public func addPathHandler<Path>(
        priority: Priority = .medium,
        pathHandler: @escaping ClosurePathHandler<Path>
    ) -> PathHandler {
        let handler = Shepherd.ClosurePathHandler(handler: pathHandler)
        add(child: handler, priority: priority)
        return handler
    }

    /**
     Add the provided closure to be a path handler.

     When the closure is called it should attempt to handle the path. If the path is handled the closure should be
     called with `true`, otherwise the closure should be called with `false`.

     - Parameter pathType: The path type to handle. Pass this to aid with type checking.
     - Parameter priority: The priority of the handler. Defaults to medium.
     - Parameter pathHandler: A closure that will be queried when handling a path of type `Path`
     */
    @discardableResult
    public func addHandlerForPaths<Path>(
        ofType pathType: Path.Type,
        priority: Priority = .medium,
        pathHandler: @escaping ClosurePathHandler<Path>
    ) -> PathHandler {
        return addPathHandler(priority: priority, pathHandler: pathHandler)
    }

}
