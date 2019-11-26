# Shepherd

[![Build Status](https://github.com/JosephDuffy/Shepherd/workflows/Tests/badge.svg)](https://launch-editor.github.com/actions?workflowID=Tests&event=push&nwo=JosephDuffy%2FShepherd)
[![Documentation](https://josephduffy.github.io/Shepherd/badge.svg)](https://josephduffy.github.io/Shepherd/)
![Compatible with macOS, iOS, watchOS, tvOS, and Linux](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4BC51D.svg)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Shepherd)
[![MIT License](https://img.shields.io/badge/License-MIT-4BC51D.svg?style=flat)](./LICENSE)

Shepherd is a router implementation to help guide routes in your app.

```swift
let tabsRouter = Router()
let firstTabRouter = Router()
let secondTabRouter = Router()
tabsRouter.add(child: firstTabRouter)
tabsRouter.add(child: secondTabRouter)
tabsRouter.addHandlerForPaths(ofType: String.self) { path, completionHandler in
    if path == "show-about-screen" {
        // Select tab
    }
    completionHandler(false)
}

secondTabRouter.addHandlerForPaths(ofType: String.self) { path, completionHandler in
    if path == "show-about-screen" {
        // Push about screen
        completionHandler(true)
    } else {
        completionHandler(false)
    }
}

firstTabRouter.handle(path: "show-about-screen")
```

# Documentation

Shepherd is fully documented, with [code-level documentation available online](https://josephduffy.github.io/Shepherd/). The online documentation is generated from the source code with every release, so it is up-to-date with the latest release, but may be different to the code in `master`.

## Usage overview

Shepherd has 2 primary types to aid with routing: `Router` and `PathHandler`. `PathHandler` is a protocol with a single requirement:

```swift
public protocol PathHandler: class {
    func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?)
}
```

`Router` is an `open class` that enables the creation of a tree of path handlers, and implements the `PathHandler` protocol itself.

```swift
open class Router: PathHandler {

    public typealias CompletionHandler = (_ routeHandler: Router?) -> Void

    public internal(set) weak var parent: Router?

    public init()

    public func handle<Path>(path: Path, completionHandler: ((PathHandler?) -> Void)?)

    open func handle<Path>(path: Path, ignoring: [Router] = [], completionHandler: ((PathHandler?) -> Void)? = nil)

    open func add(child pathHandler: PathHandler, priority: Priority = .medium)

    open func remove(child pathHandler: PathHandler)
```

`Router`s will query children when the `handle` function is called in priority order. If no children handle the path it will be passed to the parent (if present).

Children can query their own children, allowing for a tree of handlers to be created. For example, with the following tree:

```
     (A)
    /   \
   (B)  (C)
  / | \    \
(D)(E)(F)  (G)
```
If handler (B) is queried and (C) can handle the path the handlers would be called in the following order:

 - D
 - E
 - F
 - A
 - C

This would result in (C) being returned.

## The `path` Parameter

The type of the `path` parameter is not restricted in any way. When using the convenience `addHandlerForPaths(ofType:priority:pathHandler:)` or `addPathHandler(priority:pathHandler:)` functions the provided closure will only be called when the path is the same type as the provided closure accepts, but the parent router will still attempt to handle all router.

This flexibility can make it hard to decide which types to use. While this is ultimately the developer's decision to make, some examples of useful types are:

 - `URL`
   - This can be make it easier to support universal links if a web version of the app exists.
 - `NSUserActivity`
   - This can help when supporting certain system features, e.g., handoff, Siri, and Spotlight.
 - Custom enums
   - Enums can make the handling of a route easier. For example, a `SettingsRoute` enum can aid with autocomplete and code safety.

# Tests and CI

Shepherd has a full test suite, which is run as part of pull requests. All tests must pass for a pull request to be merged.

Code coverage is collected and reported to to [Codecov](https://codecov.io/gh/JosephDuffy/Shepherd). The codebase has 100% coverage. PRs will not be accepted that lower the coverage, unless the uncovered lines should never be hit but are required for type-safety, or are not tracked by Swift, e.g. `deinit` functions.

# Installation

## SwiftPM

To install via [SwiftPM](https://github.com/apple/swift-package-manager) add the package to the dependencies section and as the dependency of a target:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/Shepherd.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["Shepherd"]),
    ],
    ...
)
```

## Carthage

To install via [Carthage](https://github.com/Carthage/Carthage) add to following to your `Cartfile`:

```
github "JosephDuffy/Shepherd"
```

Run `carthage update Shepherd` to build the framework and then drag the built framework file in to your Xcode project. Shepherd provides pre-compiled binaries, [which can cause some issues with symbols](https://github.com/Carthage/Carthage#dwarfs-symbol-problem). Use the `--no-use-binaries` flag if this is an issue.

Remember to [add Shepherd to your Carthage build phase](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos):

```
$(SRCROOT)/Carthage/Build/iOS/Shepherd.framework
```

and

```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Shepherd.framework
```

## CocoaPods

To install via [CocoaPods](https://cocoapods.org) add the following to your Podfile:

```ruby
pod 'Shepherd'
```

and then run `pod install`.

# License

The project is released under the MIT license. View the [LICENSE](./LICENSE) file for the full license.
