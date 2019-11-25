internal final class ClosurePathHandler<Path>: PathHandler {

    internal typealias Handler = (_ route: Path, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

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

     - Parameter pathHandler: A closure that will be queried when handling a path of type `Path`
     - Parameter priority: The priority of the handler.
     */
    @discardableResult
    public func add<Path>(
        pathHandler: @escaping ClosurePathHandler<Path>,
        priority: Priority = .medium
    ) -> PathHandler {
        let handler = Shepherd.ClosurePathHandler(handler: pathHandler)
        add(child: handler, priority: priority)
        return handler
    }

}