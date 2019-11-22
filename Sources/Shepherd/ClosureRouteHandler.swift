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

    public typealias ClosurePathHandler<Path> = (_ path: Path, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    @discardableResult
    public func add<Route>(
        routeHandler: @escaping ClosurePathHandler<Route>,
        priority: Priority = .medium
    ) -> PathHandler {
        let handler = Shepherd.ClosurePathHandler(handler: routeHandler)
        add(child: handler, priority: priority)
        return handler
    }

}
