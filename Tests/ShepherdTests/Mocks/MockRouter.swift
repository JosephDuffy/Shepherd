import Shepherd

class MockRouter<PathType: Equatable>: Router {

    private(set) var latestHandleParameters: (path: Any, ignoring: [Router], completionHandler: ((Router?) -> Void)?)?

    var routeToHandle: PathType?

    override func handle<Path>(path: Path, ignoring: [Router] = [], completionHandler: ((PathHandler?) -> Void)? = nil) {
        latestHandleParameters = (path, ignoring, completionHandler)

        if let routeToHandle = routeToHandle, let route = path as? PathType, routeToHandle == route {
            completionHandler?(self)
            return
        }

        super.handle(path: path, ignoring: ignoring, completionHandler: completionHandler)
    }

}