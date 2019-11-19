import Shepherd

class MockRouter<RouteType: Equatable>: Router {

    private(set) var latestHandleParameters: (route: Any, ignoring: [Router], completionHandler: ((Router?) -> Void)?)?

    var routeToHandle: RouteType?

    override func handle<Route>(route: Route, ignoring: [Router] = [], completionHandler: ((RouteHandler?) -> Void)? = nil) {
        latestHandleParameters = (route, ignoring, completionHandler)

        if let routeToHandle = routeToHandle, let route = route as? RouteType, routeToHandle == route {
            completionHandler?(self)
            return
        }

        super.handle(route: route, ignoring: ignoring, completionHandler: completionHandler)
    }

}
