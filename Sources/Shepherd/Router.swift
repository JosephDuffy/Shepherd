import Foundation

/**
 An object that routes paths to a set of connected routers. Child router are added via the `add(child:priority:)`
 function. When the router is requested to handle a route it will query the children by priority order. If 2
 children have identical priorities they will be queried in the order they were added.
 */
open class Router {

    /// A closure that will be notified when a route is handled.
    /// - parameter routeHandler: The route handler that handled the route.
    public typealias CompletionHandler = (_ routeHandler: Router?) -> Void

    /// The immediate parent. This will be set automatically by the parent.
    /// The parent has a priority of `Priority.parent`, making it the last router to be queried.
    public weak var parent: Router?

    /// An array of children that have been added to the router, sorted in decending priority.
    public var children: [Router] {
        return _children.keys.sorted(by: >).flatMap { _children[$0]! }
    }

    /// An array of the adjacent router in the tree of router, ordered by priority. If the
    /// priority of 2 routers are the same they will be ordered by the order they were added.
    private var routeHandlers: [Router] {
        var tree = _children
        parent.map { tree[.parent, default: []].append($0) }
        return tree.keys.sorted(by: >).flatMap { tree[$0]! }
    }

    /// An array of children that have been added to the router.
    private var _children: [Priority: [Router]] = [:]

    /// Create an empty router.
    public init() {}

    /**
     Attempt to handle the provided path. The child routers will be sorted by their priorities using the standard
     library `sorted` function; the sorting algorithm is not guaranteed to be stable, although this is unlikely to
     change in the future. See https://forums.swift.org/t/is-sort-stable-in-swift-5/21297/11.

     The completion closure will be called with the router that handled the path, or `nil` if the path was not handled.

     - Parameter path: The path to attempt to handle.
     - Parameter ignoring: An array of routers to ignore when traversing the tree of routers.
     - Parameter completionHandler: A closure that will be called with the router that handled the path, or `nil`
                                    if the path was not handled.
     */
    open func handle<Path>(
        path: Path,
        ignoring: [Router] = [],
        completionHandler: ((Router?) -> Void)? = nil
    ) {
        var iterator = routeHandlers.makeIterator()

        var ignoringIncludingSelf = ignoring
        ignoringIncludingSelf.append(self)

        func tryNext() {
            guard let router = iterator.next() else {
                completionHandler?(nil)
                return
            }

            guard !ignoring.contains(where: { $0 === router }) else {
                tryNext()
                return
            }

            router.handle(path: path, ignoring: ignoringIncludingSelf) { pathHandler in
                if let pathHandler = pathHandler {
                    completionHandler?(pathHandler)
                } else {
                    tryNext()
                }
            }
        }

        tryNext()
    }

    /**
     Add the provided router as a child of this router. The added child will be queried when attempting to handle
     a path via `handle(path:ignoring:completionHandler:)`.

     If the provided router is an existing child of this router the priority will be updated.

     - Parameter router: The router to add as a child.
     - Parameter priority: The priority to assign to the child. Defaults to `.medium`.
     */
    open func add(child router: Router, priority: Priority = .medium) {
        remove(child: router)
        _children[priority, default: []].append(router)
        router.parent = self
    }

    /**
     Remove the provided router from the set of router that will be queried by this router. If the router
     is a child of this router the parent will be set to `nil`. If it is not a child this function does nothing.

     - Parameter router: The router to remove.
     */
    open func remove(child router: Router) {
        for priority in _children.keys {
            var children = _children[priority]!
            guard let childIndex = children.firstIndex(where: { $0 === router }) else { continue }
            children.remove(at: childIndex)
            _children[priority] = children
            router.parent = nil
            return
        }
    }

}
