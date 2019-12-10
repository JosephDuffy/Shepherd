/**
 A class that can be queried to handle paths.
 */
public protocol PathHandler: class {
    
    /// The immediate parent of the path handler. The parent should be held on to weakly.
    var parent: PathHandler? { get set }

    /**
     Attempt to handle the provided path. The path can be any type, but the handler does not have to attempt to handle
     all path types.

     If the provided path cannot be handled the implementation must call the `completionHandler` with `nil`. If the
     provided path has been handled the implementation must call the `completionHandler` with the path handler that
     handled the path.

     - Parameter path: The path to attempt to handle.
     - Parameter completionHandler: A closure that must be called when the path handler has handled or has determined it
                                    is unable to handle the provided path.
     */
    func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?)

}
