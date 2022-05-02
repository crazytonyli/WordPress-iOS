import XCTest
@testable import WordPress

final class ActivityContentRouterTests: XCTestCase {

    let testData = ActivityLogTestData()
    var testCoordinator: MockContentCoordinator!

    override func setUp() {
        super.setUp()
        testCoordinator = MockContentCoordinator()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRouteToComment() throws {
        let commentActivity = FormattableActivity(with: try Activity.fixture(.commentEvent))
        let router = ActivityContentRouter(activity: commentActivity, coordinator: testCoordinator)

        router.routeTo(commentURL)

        XCTAssertTrue(testCoordinator.commentsWasDisplayed)
        XCTAssertEqual(testCoordinator.commentPostID?.intValue, testData.testPostID)
        XCTAssertEqual(testCoordinator.commentSiteID?.intValue, testData.testSiteID)
    }

    func testRouteToPost() throws {
        let activity = FormattableActivity(with: try Activity.fixture(.postEvent))
        let router = ActivityContentRouter(activity: activity, coordinator: testCoordinator)

        router.routeTo(postURL)

        XCTAssertTrue(testCoordinator.readerWasDisplayed)
        XCTAssertEqual(testCoordinator.readerPostID?.intValue, testData.testPostID)
        XCTAssertEqual(testCoordinator.readerSiteID?.intValue, testData.testSiteID)
    }
}

// MARK: - Helpers

extension ActivityContentRouterTests {
    var postURL: URL {
        return URL(string: testData.testPostUrl)!
    }

    var commentURL: URL {
        return URL(string: testData.testCommentURL)!
    }

}
