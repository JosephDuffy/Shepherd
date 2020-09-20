open class PathExecutor<Path> {

    public typealias ExecutionResult = Result<Router, Error>

    public typealias CompletionHandler = (Result<Router, Error>) -> Void

    public enum Error: Swift.Error {
        case unhandledPath(Path)
    }

    public struct Context {
        public let path: Path

        public let initialRouter: Router

        public let routersToIgnore: [Router]

        public let previous: PathExecutor<Path>?
    }

    public let context: Context

    public let completionHandler: CompletionHandler?

    public init(path: Path, initialRouter: Router, routersToIgnore: [Router], previous: PathExecutor<Path>?, completionHandler: CompletionHandler?) {
        context = Context(path: path, initialRouter: initialRouter, routersToIgnore: routersToIgnore, previous: previous)
        self.completionHandler = completionHandler
    }

    open func execute() {
        let routersIterator = context.initialRouter.routeHandlers.makeIterator()
        tryNext(iterator: routersIterator)
    }

    open func tryRouter(_ router: Router) {
        let routersIterator = router.routeHandlers.makeIterator()
        tryNext(iterator: routersIterator)
    }

    open func tryNext(iterator: IndexingIterator<[Router]>) {
        var iterator = iterator

        guard let router = iterator.next() else {
            completionHandler?(.failure(Error.unhandledPath(context.path)))
            return
        }

        guard !context.routersToIgnore.contains(where: { $0 === router }) else {
            tryNext(iterator: iterator)
            return
        }

        guard context.previous?.context.initialRouter !== router else {
            tryNext(iterator: iterator)
            return
        }

        router.handle(path: context.path, ignoring: context.routersToIgnore, executor: self) { pathHandler in
            if let pathHandler = pathHandler {
                self.completionHandler?(.success(pathHandler))
            } else {
                self.tryNext(iterator: iterator)
            }
        }
    }

}
