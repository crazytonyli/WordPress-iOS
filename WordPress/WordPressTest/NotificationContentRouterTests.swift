
import XCTest
@testable import WordPress

class NotificationContentRouterTests: XCTestCase {

    var contextManager: TestContextManager!
    var sut: NotificationContentRouter!
    var coordinator: MockContentCoordinator!

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
        coordinator = MockContentCoordinator()
    }

    override func tearDown() {
        ContextManager.overrideSharedInstance(nil)
        super.tearDown()
    }

    func testFollowNotificationSourceRoutesToStream() throws {
        sut = NotificationContentRouter(
            activity: try .fixture(.newFollower, insertInto: contextManager.mainContext),
            coordinator: coordinator
        )
        try! sut.routeToNotificationSource()

        XCTAssertTrue(coordinator.streamWasDisplayed)
    }
}
