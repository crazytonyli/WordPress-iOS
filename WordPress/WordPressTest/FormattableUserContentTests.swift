import XCTest
@testable import WordPress

final class FormattableUserContentTests: XCTestCase {
    private let contextManager = TestContextManager()
    private let entityName = Notification.classNameWithoutNamespaces()

    private var subject: FormattableUserContent?

    private struct Expectations {
        static let text = "someonesomeone"
        static let approveAction = ApproveCommentAction(on: true, command: ApproveComment(on: true))
        static let trashAction = TrashCommentAction(on: true, command: TrashComment(on: true))
        static let metaTitlesHome = "a title"
        static let metaTitlesHomeURL = URL(string: "http://someone.wordpress.com")
        static let notificationId = "11111"
        static let metaSiteId = NSNumber(integerLiteral: 136505344)

        static let imageURL = URL(string: "https://2.gravatar.com/avatar/1111")!
        static let testImage = UIImage()
        static let imageRange = NSRange(location: 0, length: 0)
        static let mappedMediaRanges = [NSValue(range: imageRange): testImage]
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        subject = FormattableUserContent(
            dictionary: try Fixtures.NotificationContent.user.jsonObject(),
            actions: mockedActions(),
            ranges: [],
            parent: try Fixtures.Notification.like.insertInto(contextManager.mainContext)
        )
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func testKindReturnsExpectation() {
        let notificationKind = subject?.kind

        XCTAssertEqual(notificationKind, .user)
    }

    func testStringReturnsExpectation() {
        let value = subject?.text

        XCTAssertEqual(value, Expectations.text)
    }

    func testRangesAreEmpty() {
        let value = subject?.ranges

        XCTAssertEqual(value?.count, 0)
    }

    func testActionsReturnMockedActions() {
        let value = subject?.actions
        let mockActionsCount = mockedActions().count

        XCTAssertEqual(value?.count, mockActionsCount)
    }

    func testBuildRangesToImagesMapsCorrectly() {
        let mediaMap = [Expectations.imageURL: Expectations.testImage]
        let value = subject?.buildRangesToImagesMap(mediaMap)
        XCTAssertNotNil(value)
        XCTAssertEqual(value!, Expectations.mappedMediaRanges)
    }

    func testImageUrlsReturnExpectations() {
        XCTAssertEqual(subject?.imageUrls, [Expectations.imageURL])
    }

    func testMetaReturnsExpectation() throws {
        let value = subject!.meta!
        let ids = value["ids"] as? [String: AnyObject]
        let userId = ids?["user"] as? String
        let siteId = ids?["site"] as? String

        let mockMeta = try Fixtures.jsonObject(fromFile: "notifications-user-content-meta.json")
        let mockIds = mockMeta["ids"] as? [String: AnyObject]
        let mockMetaUserId = mockIds?["user"] as? String
        let mockMetaSiteId = mockIds?["site"] as? String

        XCTAssertEqual(userId, mockMetaUserId)
        XCTAssertEqual(siteId, mockMetaSiteId)
    }

    func testParentReturnsValuePassedAsParameter() throws {
        let injectedParent = try Fixtures.Notification.like.insertInto(contextManager.mainContext)

        let parent = subject?.parent

        XCTAssertEqual(parent?.notificationIdentifier, injectedParent.notificationIdentifier)
    }

    func testApproveCommentActionIsOn() {
        let approveCommentIdentifier = ApproveCommentAction.actionIdentifier()
        let on = subject?.isActionOn(id: approveCommentIdentifier)
        XCTAssertTrue(on!)
    }

    func testApproveCommentActionIsEnabled() {
        let approveCommentIdentifier = ApproveCommentAction.actionIdentifier()
        let on = subject?.isActionEnabled(id: approveCommentIdentifier)
        XCTAssertTrue(on!)
    }

    func testActionWithIdentifierReturnsExpectedAction() {
        let approveCommentIdentifier = ApproveCommentAction.actionIdentifier()
        let action = subject?.action(id: approveCommentIdentifier)
        XCTAssertEqual(action?.identifier, approveCommentIdentifier)
    }

    func testMetaTitlesHomeAsStringReturnsExpectation() {
        let home: String? = subject?.metaTitlesHome
        XCTAssertEqual(home, Expectations.metaTitlesHome)
    }

    func testMetaTitlesHomeAsURLReturnsExpectation() {
        let home: URL? = subject?.metaLinksHome
        XCTAssertEqual(home, Expectations.metaTitlesHomeURL)
    }

    func testNotificationIdReturnsExpectation() {
        let id = subject?.notificationID
        XCTAssertEqual(id, Expectations.notificationId)
    }

    func testMetaSiteIdReturnsExpectation() {
        let id = subject?.metaSiteID
        XCTAssertEqual(id, Expectations.metaSiteId)
    }

    private func mockedActions() -> [FormattableContentAction] {
        return [Expectations.approveAction,
                Expectations.trashAction]
    }
}
