#if os(iOS)
import UIKit
import Quick
import Nimble
@testable import Shepherd

@available(iOS 9.0, *)
final class UIApplicationShortcutItemUserActivityTests: QuickSpec {

    override func spec() {
        describe("UIApplicationShortcutItem") {
            context("with no data in the user info dictionary") {
                var shortcutItem: UIApplicationShortcutItem!

                beforeEach {
                    shortcutItem = UIApplicationShortcutItem(type: "test-shortcut", localizedTitle: "Test")
                }

                context("userActivity property") {
                    it("should be `nil`") {
                        expect(shortcutItem.userActivity).to(beNil())
                    }
                }
            }

            context("with invalid data in the user info dictionary") {
                var shortcutItem: UIApplicationShortcutItem!

                beforeEach {
                    shortcutItem = UIApplicationShortcutItem(
                        type: "test-shortcut",
                        localizedTitle: "Test",
                        localizedSubtitle: nil,
                        icon: nil,
                        userInfo: [
                            "userActivityData": NSData()
                        ]
                    )
                }

                context("userActivity property") {
                    it("should be `nil`") {
                        expect(shortcutItem.userActivity).to(beNil())
                    }
                }
            }

            if #available(iOS 11, *) {
                context("initialised with a `SecureCodingUserActivity`") {
                    var shortcutItem: UIApplicationShortcutItem!
                    var encodedUserActivity: SecureCodingUserActivity!
                    var thrownError: Error?

                    beforeEach {
                        encodedUserActivity = SecureCodingUserActivity(encodedProperty: "test-value")
                        do {
                            shortcutItem = try UIApplicationShortcutItem(
                                userActivity: encodedUserActivity,
                                localizedTitle: "Test Encoding",
                                localizedSubtitle: nil,
                                icon: nil
                            )
                        } catch {
                            thrownError = error
                        }
                    }

                    afterEach {
                        shortcutItem = nil
                        thrownError = nil
                    }

                    it("should not throw an error") {
                        expect(thrownError).to(beNil())
                    }

                    context("userActivity property") {
                        it("should be an instance of `SecureCodingUserActivity`") {
                            expect(shortcutItem.userActivity).to(beAnInstanceOf(SecureCodingUserActivity.self))
                        }

                        it("should equal the encoded user activity") {
                            expect(shortcutItem.userActivity) == encodedUserActivity
                        }
                    }
                }

                context("initialised with a user activity that fails encoding") {
                    var expectedError: Error!
                    var encodedUserActivity: FailingSecureCodingUserActivity!
                    var thrownError: NSError!

                    beforeEach {
                        expectedError = FailingSecureCodingUserActivity.EncodingError.testError
                        encodedUserActivity = FailingSecureCodingUserActivity()
                        encodedUserActivity.errorToFailWith = expectedError
                        do {
                            _ = try UIApplicationShortcutItem(
                                userActivity: encodedUserActivity,
                                localizedTitle: "Test Encoding",
                                localizedSubtitle: nil,
                                icon: nil
                            )
                        } catch {
                            thrownError = error as NSError
                        }
                    }

                    afterEach {
                        thrownError = nil
                    }

                    it("should throw an error with the underlying error that failed the encoding") {
                        expect(
                            thrownError.userInfo[NSUnderlyingErrorKey] as? Error
                        ).to(
                            matchError(expectedError)
                        )
                    }
                }

                context("initialised with a user activity that fails decoding") {
                    var shortcutItem: UIApplicationShortcutItem!
                    var encodedUserActivity: FailingSecureCodingUserActivity!
                    var thrownError: NSError!

                    beforeEach {
                        encodedUserActivity = FailingSecureCodingUserActivity()
                        do {
                            shortcutItem = try UIApplicationShortcutItem(
                                userActivity: encodedUserActivity,
                                localizedTitle: "Test Encoding",
                                localizedSubtitle: nil,
                                icon: nil
                            )
                        } catch {
                            thrownError = error as NSError
                        }
                    }

                    afterEach {
                        shortcutItem = nil
                        thrownError = nil
                    }

                    it("should not throw an error") {
                        expect(thrownError).to(beNil())
                    }

                    context("userActivity property") {
                        it("should be `nil`") {
                            expect(shortcutItem.userActivity).to(beNil())
                        }
                    }
                }
            }
        }
    }

}
#endif
