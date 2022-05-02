import XCTest
@testable import WordPress

final class NotificationTextContentTests: XCTestCase {
    private var contextManager: TestContextManager!
    private let entityName = Notification.classNameWithoutNamespaces()

    private var subject: NotificationTextContent?

    private struct Expectations {
        static let text = "xxxxxx xxxxxx and 658 others liked your post Bookmark Posts with Save For Later"
        static let approveAction = ApproveCommentAction(on: true, command: ApproveComment(on: true))
        static let trashAction = TrashCommentAction(on: true, command: TrashComment(on: true))
    }

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
        subject = NotificationTextContent(
            dictionary: mockDictionary(),
            actions: mockedActions(),
            ranges: [],
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        )
    }

    override func tearDown() {
        ContextManager.overrideSharedInstance(nil)
        subject = nil
        super.tearDown()
    }

    func testKindReturnsExpectation() {
        let notificationKind = subject?.kind

        XCTAssertEqual(notificationKind, .text)
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

    func testMetaReturnsExpectation() {
        let value = subject?.meta

        XCTAssertNil(value)
    }

    func testKindReturnsButtonForButtonContent() {
        subject = NotificationTextContent(
            dictionary: mockButtonContentDictionary(),
            actions: mockedActions(),
            ranges: [],
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        )
        let notificationKind = subject?.kind

        XCTAssertEqual(notificationKind, .button)
    }

    func testParentReturnsValuePassedAsParameter() {
        let injectedParent = WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)

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

    private func mockDictionary() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "notifications-text-content.json")
    }

    private func mockButtonContentDictionary() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "notifications-button-text-content.json")
    }

    private func getDictionaryFromFile(named fileName: String) -> [String: AnyObject] {
        return JSONLoader().loadFile(named: fileName) ?? [:]
    }

    private func mockedActions() -> [FormattableContentAction] {
        return [Expectations.approveAction,
                Expectations.trashAction]
    }
}
