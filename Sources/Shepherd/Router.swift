import Foundation

open class Router: PathHandler {

    /// A closure that will be notified when a route is handled.
    /// - parameter routeHandler: The route handler that handled the route.
    public typealias CompletionHandler = (_ routeHandler: Router?) -> Void

    /// The immediate parent. This will be set automatically by the parent.
    public internal(set) weak var parent: Router?

    private var routeHandlers: [LinkedHandler] {
        var tree = children
        parent.map { LinkedHandler(router: $0, priority: .low) }.map { tree.append($0) }
        return tree.stableSorted(by: >)
    }

    /// Create an empty route handler.
    public init() {}

    public func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?) {
        handle(path: path, ignoring: [], completionHandler: completionHandler)
    }

    /**
     Tries to handle a provided path. The child routers will be sorted by their priorities and then the order they were
     added in; routers with the same priorty are tried in the order they were added.

     - Parameter path: The path to attempt to handle.
     - Parameter ignoring: An array of routers to ignore when traversing the children.
     - Parameter completionHandler: An optional closure that will be called when the route has
     */
    open func handle<Path>(
        path: Path,
        ignoring: [Router] = [],
        completionHandler: ((PathHandler?) -> Void)? = nil
    ) {
        var iterator = routeHandlers.makeIterator()

        var ignoringIncludingSelf = ignoring
        ignoringIncludingSelf.append(self)

        func tryNext() {
            guard let next = iterator.next() else {
                completionHandler?(nil)
                return
            }

            guard !ignoring.contains(where: { $0 === next.pathHandler }) else {
                tryNext()
                return
            }

            if let router = next.router {
                router.handle(path: path, ignoring: ignoringIncludingSelf) { pathHandler in
                    if let pathHandler = pathHandler {
                        completionHandler?(pathHandler)
                    } else {
                        tryNext()
                    }
                }
            } else {
                next.pathHandler.handle(path: path) { pathHandler in
                    if let pathHandler = pathHandler {
                        completionHandler?(pathHandler)
                    } else {
                        tryNext()
                    }
                }
            }
        }

        tryNext()
    }

    private var children: [LinkedHandler] = []

    open func add(child pathHandler: PathHandler, priority: Priority = .medium) {
        if let router = pathHandler as? Router {
            let child = LinkedHandler(router: router, priority: priority)
            children.append(child)
            router.parent = self
        } else {
            let child = LinkedHandler(routeHandler: pathHandler, priority: priority)
            children.append(child)
        }
    }

    open func remove(child pathHandler: PathHandler) {
        children.removeAll(where: { child in
            return child.pathHandler === pathHandler
        })
    }

}

extension Router {

    private struct LinkedHandler: Comparable {

        private enum Kind {
            case router(Router)
            case handler(PathHandler)
        }

        static func == (lhs: LinkedHandler, rhs: LinkedHandler) -> Bool {
            guard lhs.priority == rhs.priority else { return false }
            guard lhs.uuid == rhs.uuid else { return false }
            return true
        }

        public static func < (lhs: LinkedHandler, rhs: LinkedHandler) -> Bool {
            return lhs.priority < rhs.priority
        }

        private let kind: Kind
        var priority: Priority
        private let uuid = UUID()

        var pathHandler: PathHandler {
            switch kind {
            case .router(let router):
                return router
            case .handler(let pathHandler):
                return pathHandler
            }
        }

        var router: Router? {
            switch kind {
            case .router(let router):
                return router
            case .handler:
                return nil
            }
        }

        init(router: Router, priority: Priority) {
            kind = .router(router)
            self.priority = priority
        }

        init(routeHandler: PathHandler, priority: Priority) {
            kind = .handler(routeHandler)
            self.priority = priority
        }

    }

}
