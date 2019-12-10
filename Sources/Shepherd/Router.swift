import Foundation

/**
 An object that routes paths to a set of connected path handlers. Path handlers are added via the `add(child:priority:)`
 function. When the router is requested to handle a route it will query the path handles by priority order. If 2
 handlers have identical priorities they will be queried in the order they were added.
 */
open class Router: PathHandler {

    /// A closure that will be notified when a route is handled.
    /// - parameter routeHandler: The route handler that handled the route.
    public typealias CompletionHandler = (_ routeHandler: Router?) -> Void

    /// The immediate parent. This will be set automatically by the parent.
    /// The parent has a priority of `Priority.parent`, making it the last path handler to be queried.
    public weak var parent: PathHandler?

    /// An array of children that have been added to the router, sorted in decending priority.
    public var children: [PathHandler] {
        return _children.sorted(by: { $0.priority > $1.priority }).map { $0.pathHandler }
    }

    /// An array of the adjacent nodes in the tree of path handlers, ordered by the priority of the handlers. If the
    /// priority of 2 handlers are the same they will be ordered by order they were added.
    private var routeHandlers: [LinkedHandler] {
        var tree = _children
        parent.map { LinkedHandler(pathHandler: $0, priority: .low) }.map { tree.append($0) }
        return tree.sorted(by: { $0.priority > $1.priority })
    }

    /// An array of children that have been added to the router.
    private var _children: [LinkedHandler] = []

    /// Create an empty router.
    public init() {}

    /**
     Attempt to handle the provided path. The child path handlers will be sorted by their priorities using the standard
     library `sorted` function; the sorting algorithm is not guaranteed to be stable, although this is unlikely to
     change in the future. See https://forums.swift.org/t/is-sort-stable-in-swift-5/21297/11.

     The completion closure will be called with the path handler that handled the path, or `nil` if the path was not
     handled.

     - Parameter path: The path to attempt to handle.
     - Parameter completionHandler: A closure that will be called with the path handler that handled the path, or `nil`
                                    if the path was not handled.
     */
    public func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?) {
        handle(path: path, ignoring: [], completionHandler: completionHandler)
    }

    /**
     Attempt to handle the provided path. The child path handlers will be sorted by their priorities using the standard
     library `sorted` function; the sorting algorithm is not guaranteed to be stable, although this is unlikely to
     change in the future. See https://forums.swift.org/t/is-sort-stable-in-swift-5/21297/11.

     The completion closure will be called with the path handler that handled the path, or `nil` if the path was not
     handled.

     - Parameter path: The path to attempt to handle.
     - Parameter ignoring: An array of path handlers to ignore when traversing the tree of handlers.
     - Parameter completionHandler: A closure that will be called with the path handler that handled the path, or `nil`
                                    if the path was not handled.
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

    /**
     Add the provided path handler as a child of the router. The added child will be queried when attempting to handle
     a path via `handle(path:completionHandler:)`.

     If the provided path handler is an existing child of this router the priority will be updated.

     - Parameter pathHandler: The path handler to add a child.
     - Parameter priority: The priority to assign to the child. Defaults to `.medium`.
     */
    open func add(child pathHandler: PathHandler, priority: Priority = .medium) {
        if let existingChild = _children.first(where: { $0.pathHandler === pathHandler }) {
            existingChild.priority = priority
        } else if let router = pathHandler as? Router {
            let child = LinkedHandler(pathHandler: router, priority: priority)
            _children.append(child)
            router.parent = self
        } else {
            let child = LinkedHandler(pathHandler: pathHandler, priority: priority)
            _children.append(child)
        }
    }

    /**
     Remove the provided path handler from the array of path handlers that will be queried by this router. If the path
     handler is a child of this router the parent will be set to `nil`. If it is not a child this function does nothing.

     - Parameter pathHandler: The path handler to remove.
     */
    open func remove(child pathHandler: PathHandler) {
        guard let childIndex = _children.firstIndex(where: { $0.pathHandler === pathHandler }) else { return }
        let child = _children.remove(at: childIndex)
        child.router?.parent = nil
    }

}

extension Router {

    private final class LinkedHandler {

        var priority: Priority

        var pathHandler: PathHandler

        var router: Router? {
            return pathHandler as? Router
        }

        init(pathHandler: PathHandler, priority: Priority) {
            self.pathHandler = pathHandler
            self.priority = priority
        }

    }

}
