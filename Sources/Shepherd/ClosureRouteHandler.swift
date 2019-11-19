public final class ClosureRouteHandler<Route>: RouteHandler {

    public typealias Handler = (_ route: Route, _ completionHandler: @escaping (_ didHandle: Bool) -> Void) -> Void

    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    public func handle<AnyRoute>(route: AnyRoute, completionHandler: ((RouteHandler?) -> Void)?) {
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

    public func add<Route>(
        routeHandler: @escaping ClosureRouteHandler<Route>.Handler,
        priority: Priority = .medium
    ) {
        let handler = ClosureRouteHandler(handler: routeHandler)
        add(child: handler, priority: priority)
    }

}
