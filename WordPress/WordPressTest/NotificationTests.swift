import Foundation
import XCTest
@testable import WordPress

/// Notifications Tests
///
class NotificationTests: XCTestCase {

    var contextManager: TestContextManager!

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
    }

    override func tearDown() {
        ContextManager.overrideSharedInstance(nil)
        super.tearDown()
    }

    func testBadgeNotificationHasBadgeFlagSetToTrue() {
        let note = WordPress.Notification.fixture(.badge, insertInto: contextManager.mainContext)
        XCTAssertTrue(note.isBadge)
    }

    func testBadgeNotificationHasRegularFieldsSet() {
        let note = WordPress.Notification.fixture(.badge, insertInto: contextManager.mainContext)
        XCTAssertNotNil(note.type)
        XCTAssertNotNil(note.noticon)
        XCTAssertNotNil(note.iconURL)
        XCTAssertNotNil(note.resourceURL)
        XCTAssertNotNil(note.timestampAsDate)
    }

    func testBadgeNotificationProperlyLoadsItsSubjectContent() {
        let note = WordPress.Notification.fixture(.badge, insertInto: contextManager.mainContext)

        XCTAssert(note.subjectContentGroup?.blocks.count == 1)
        XCTAssertNotNil(note.subjectContentGroup?.blocks.first)
        XCTAssertNotNil(note.renderSubject())
    }

    func testBadgeNotificationContainsOneImageContentGroup() {
        let note = WordPress.Notification.fixture(.badge, insertInto: contextManager.mainContext)
        let group = note.contentGroup(ofKind: .image)
        XCTAssertNotNil(group)

        let imageBlock = group?.blocks.first as? FormattableMediaContent
        XCTAssertNotNil(imageBlock)

        let media = imageBlock?.media.first
        XCTAssertNotNil(media)
        XCTAssertNotNil(media?.mediaURL)
    }

    func testLikeNotificationReturnsTheProperKindValue() {
        let note = WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        XCTAssert(note.kind == .like)
    }

    func testLikeNotificationContainsHeaderContent() {
        let note = WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        let header = note.headerContentGroup
        XCTAssertNotNil(header)

        let gravatarBlock: NotificationTextContent? = header?.blockOfKind(.image)
        XCTAssertNotNil(gravatarBlock?.text)

        let media = gravatarBlock?.media.first
        XCTAssertNotNil(media?.mediaURL)

        let snippetBlock: NotificationTextContent? = header?.blockOfKind(.text)
        XCTAssertNotNil(snippetBlock?.text)
    }


    func testLikeNotificationContainsUserContentGroupsInTheBody() {
        let note = WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        for group in note.bodyContentGroups {
            XCTAssertTrue(group.kind == .user)
        }
    }

    func testLikeNotificationContainsPostAndSiteID() {
        let note = WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        XCTAssertNotNil(note.metaSiteID)
        XCTAssertNotNil(note.metaPostID)
    }

    func testFollowerNotificationReturnsTheProperKindValue() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)
        XCTAssert(note.kind == .follow)
    }

    func testFollowerNotificationHasFollowFlagSetToTrue() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)
        XCTAssertTrue(note.kind == .follow)
    }

    func testFollowerNotificationContainsOneSubjectContent() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)

        let content = note.subjectContentGroup?.blocks.first
        XCTAssertNotNil(content)
        XCTAssertNotNil(content?.text)
    }

    func testFollowerNotificationContainsSiteID() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)
        XCTAssertNotNil(note.metaSiteID)
    }

    func testFollowerNotificationContainsUserAndFooterGroupsInTheBody() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)

        // Note: Account for 'View All Followers'
        for group in note.bodyContentGroups {
            XCTAssertTrue(group.kind == .user || group.kind == .footer)
        }
    }

    func testFollowerNotificationContainsFooterContentWithFollowRangeAtTheEnd() {
        let note = WordPress.Notification.fixture(.newFollower, insertInto: contextManager.mainContext)

        let lastGroup = note.bodyContentGroups.last
        XCTAssertNotNil(lastGroup)
        XCTAssertTrue(lastGroup!.kind == .footer)

        let block = lastGroup?.blocks.first
        XCTAssertNotNil(block)
        XCTAssertNotNil(block?.text)
        XCTAssertNotNil(block?.ranges)

        let range = block?.ranges.last
        XCTAssertNotNil(range)
        XCTAssert(range?.kind == .follow)
    }

    func testCommentNotificationReturnsTheProperKindValue() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        XCTAssert(note.kind == .comment)
    }

    func testCommentNotificationHasCommentFlagSetToTrue() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        XCTAssertTrue(note.kind == .comment)
    }

    func testCommentNotificationRendersSubjectWithSnippet() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)

        XCTAssertNotNil(note.renderSubject())
        XCTAssertNotNil(note.renderSnippet())
    }

    func testCommentNotificationContainsHeaderContent() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)

        let header = note.headerContentGroup
        XCTAssertNotNil(header)

        let gravatarBlock: NotificationTextContent? = header?.blockOfKind(.image)
        XCTAssertNotNil(gravatarBlock)
        XCTAssertNotNil(gravatarBlock?.text)

        let media = gravatarBlock!.media.first
        XCTAssertNotNil(media)
        XCTAssertNotNil(media!.mediaURL)

        let snippetBlock: NotificationTextContent? = header?.blockOfKind(.text)
        XCTAssertNotNil(snippetBlock)
        XCTAssertNotNil(snippetBlock?.text)
    }

    func testCommentNotificationContainsCommentAndSiteID() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        XCTAssertNotNil(note.metaSiteID)
        XCTAssertNotNil(note.metaCommentID)
    }

    func testCommentNotificationProperlyChecksIfItWasRepliedTo() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        XCTAssert(note.isRepliedComment)
    }

    func testCommentNotificationIsUnapproved() {
        let note = WordPress.Notification.fixture(.unapprovedComment, insertInto: contextManager.mainContext)
        XCTAssertTrue(note.isUnapprovedComment)
    }

    func testCommentNotificationIsApproved() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        XCTAssertFalse(note.isUnapprovedComment)
    }


    func testFooterContentIsIdentifiedAndCreated() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        let footerBlock: FooterTextContent? = note.contentGroup(ofKind: .footer)?.blockOfKind(.text)

        XCTAssertNotNil(footerBlock)
    }

    func testFindingContentRangeSearchingByURL() {
        let note = WordPress.Notification.fixture(.badge, insertInto: contextManager.mainContext)
        let targetURL = URL(string: "http://www.wordpress.com")!
        let range = note.contentRange(with: targetURL)

        XCTAssertNotNil(range)
    }

    func testPingbackNotificationIsPingback() {
        let notification = WordPress.Notification.fixture(.pingback, insertInto: contextManager.mainContext)
        XCTAssertTrue(notification.isPingback)
    }

    func testPingbackBodyContainsFooter() {
        let notification = WordPress.Notification.fixture(.pingback, insertInto: contextManager.mainContext)
        let footer = notification.bodyContentGroups.filter { $0.kind == .footer }
        XCTAssertEqual(footer.count, 1)
    }

    func testHeaderAndBodyContentGroups() {
        let note = WordPress.Notification.fixture(.repliedComment, insertInto: contextManager.mainContext)
        let headerGroupsCount = note.headerContentGroup != nil ? 1 : 0
        let bodyGroupsCount = note.bodyContentGroups.count
        let totalGroupsCount = headerGroupsCount + bodyGroupsCount

        XCTAssertEqual(note.headerAndBodyContentGroups.count, totalGroupsCount)
    }

}
