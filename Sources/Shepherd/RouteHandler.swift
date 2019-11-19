public protocol RouteHandler: class {
    func handle<Route>(route: Route, completionHandler: ((RouteHandler?) -> Void)?)
}
