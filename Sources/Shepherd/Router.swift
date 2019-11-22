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
            switch next.kind {
            case .router(let router):
                guard !ignoring.contains(where: { $0 === router }) else {
                    tryNext()
                    return
                }
                router.handle(path: path, ignoring: ignoringIncludingSelf) { router in
                    if let router = router {
                        completionHandler?(router)
                    } else {
                        tryNext()
                    }
                }
            case .handler(let routeHandler):
                routeHandler.handle(path: path) { routeHandler in
                    if let routeHandler = routeHandler {
                        completionHandler?(routeHandler)
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

    open func remove(router: Router) {
        children.removeAll(where: { child in
            switch child.kind {
            case .router(let childRouter):
                if router === childRouter {
                    router.parent = nil
                    return true
                } else {
                    return false
                }
            case .handler:
                return false
            }
        })
    }

}

extension Router {

    private struct LinkedHandler: Comparable {

        enum Kind {
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

        let kind: Kind
        var priority: Priority
        private let uuid = UUID()

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
