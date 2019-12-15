extension Router {

    /// The decendents of the router, in an unspecified order.
    public var decendents: [Router] {
        return children + children.flatMap { $0.decendents }
    }

}
