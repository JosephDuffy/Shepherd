internal final class SynchronousClosurePathHandler<Path>: Router {

    internal typealias Handler = Router.SynchronousClosurePathHandler<Path>

    private let handler: Handler

    internal init(handler: @escaping Handler) {
        self.handler = handler
    }

    internal override func handle<AnyPath>(
        path: AnyPath,
        ignoring: [Router] = [],
        executor previousExecutor: PathExecutor<AnyPath>? = nil,
        completionHandler: ((Router?) -> Void)? = nil
    ) {
        guard let route = path as? Path else {
            completionHandler?(nil)
            return
        }

        let didHandle = handler(route)
        completionHandler?(didHandle ? self : nil)
    }

}

extension Router {

    /**
     A closure that can be queried when attempting to handle a path.

     - Parameter path: The path to attempt to handle.
     - Parameter completionHandler: A closure to be called when the path has been handled, or it is determined the path
                                    cannot be handled.
     */
    public typealias SynchronousClosurePathHandler<Path> = (_ path: Path) -> Bool

    /**
     Add the provided closure to be a child of the router, handling routes of type `Path`.

     When the closure is called it should attempt to handle the path. If the path is handled the closure should be
     called with `true`, otherwise the closure should be called with `false`.

     - Parameter priority: The priority of the handler. Defaults to medium.
     - Parameter pathHandler: A closure that will be queried when handling a path of type `Path`.
     */
    @discardableResult
    public func addPathHandler<Path>(
        priority: Priority = .medium,
        pathHandler: @escaping SynchronousClosurePathHandler<Path>
    ) -> Router {
        let handler = Shepherd.SynchronousClosurePathHandler(handler: pathHandler)
        add(child: handler, priority: priority)
        return handler
    }

    /**
     Add the provided closure to be a child of the router, handling routes of type `Path`.

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
        pathHandler: @escaping SynchronousClosurePathHandler<Path>
    ) -> Router {
        return addPathHandler(priority: priority, pathHandler: pathHandler)
    }

}
