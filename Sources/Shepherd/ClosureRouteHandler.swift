internal final class ClosureRouteHandler<Route>: RouteHandler {

    internal typealias Handler = (_ route: Route, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    private let handler: Handler

    internal init(handler: @escaping Handler) {
        self.handler = handler
    }

    internal func handle<AnyRoute>(route: AnyRoute, completionHandler: ((RouteHandler?) -> Void)?) {
        guard let route = route as? Route else {
            completionHandler?(nil)
            return
        }

        handler(route) { didHandle in
            completionHandler?(didHandle ? self : nil)
        }
    }

}

extension Router {

    public typealias ClosureRouteHandler<Route> = (_ route: Route, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    @discardableResult
    public func add<Route>(
        routeHandler: @escaping ClosureRouteHandler<Route>,
        priority: Priority = .medium
    ) -> RouteHandler {
        let handler = Shepherd.ClosureRouteHandler(handler: routeHandler)
        add(child: handler, priority: priority)
        return handler
    }

}
