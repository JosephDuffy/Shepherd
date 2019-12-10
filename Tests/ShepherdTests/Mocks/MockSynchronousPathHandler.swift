import Shepherd

final class MockSynchronousPathHandler<PathType: Equatable>: SynchronousPathHandler {

    weak var parent: PathHandler?

    private(set) var latestHandlePath: Any?

    var pathHandlerToReturn: PathHandler?

    func handle<Path>(path: Path) -> PathHandler? {
        latestHandlePath = path
        return pathHandlerToReturn
    }

}
