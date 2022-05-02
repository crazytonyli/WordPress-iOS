import XCTest
@testable import WordPress

final class NotificationContentRangeFactoryTests: XCTestCase {
    private let contextManager = TestContextManager()

    func testCommentRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockCommentRange = try Fixture.NotificationRange.comment.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockCommentRange) as? NotificationCommentRange

        XCTAssertNotNil(subject)
    }

    func testIconRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockIconRange = try Fixture.NotificationRange.icon.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockIconRange) as? FormattableNoticonRange

        XCTAssertNotNil(subject)
    }

    func testPostRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockPostRange = try Fixture.NotificationRange.post.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockPostRange) as? NotificationContentRange

        XCTAssertNotNil(subject)
    }

    func testSiteRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockSiteRange = try Fixture.NotificationRange.site.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockSiteRange) as? NotificationContentRange

        XCTAssertNotNil(subject)
    }

    func testUserRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockUserRange = try Fixture.NotificationRange.user.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockUserRange) as? NotificationContentRange

        XCTAssertNotNil(subject)
    }

    func testDefaultRangeReturnsExpectedImplementationOfFormattableContentRange() throws {
        let mockBlockQuoteRange = try Fixture.NotificationRange.blockQuote.jsonObject()
        let subject = NotificationContentRangeFactory.contentRange(from: mockBlockQuoteRange) as? NotificationContentRange

        XCTAssertNotNil(subject)
    }
}

extension Fixture {
    enum NotificationRange: String, FixtureFile {
        case comment = "notifications-comment-range.json"
        case icon = "notifications-icon-range.json"
        case post = "notifications-post-range.json"
        case site = "notifications-site-range.json"
        case user = "notifications-user-range.json"
        case blockQuote = "notifications-blockquote-range.json"
    }
}
