import XCTest
@testable import WordPress

final class MarkAsSpamActionTests: XCTestCase {
    private class TestableMarkAsSpam: MarkAsSpam {
        let service = MockNotificationActionsService(managedObjectContext: TestContextManager.sharedInstance().mainContext)
        override var actionsService: NotificationActionsService? {
            return service
        }
    }

    private class MockNotificationActionsService: NotificationActionsService {
        override func spamCommentWithBlock(_ block: FormattableCommentContent, completion: ((Bool) -> Void)?) {
            completion?(true)
        }
    }

    private var action: MarkAsSpam?
    private let utility = NotificationUtility()
    private var contextManager = TestContextManager()

    private struct Constants {
        static let initialStatus: Bool = false
    }

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
        action = TestableMarkAsSpam(on: Constants.initialStatus)
        makeNetworkAvailable()
    }

    override func tearDown() {
        action = nil
        makeNetworkUnavailable()
        ContextManager.overrideSharedInstance(nil)
        super.tearDown()
    }

    func testStatusPassedInInitialiserIsPreserved() {
        XCTAssertEqual(action?.on, Constants.initialStatus)
    }

    func testActionTitleIsExpected() {
        XCTAssertEqual(action?.actionTitle, MarkAsSpam.title)
    }

    func testExecuteCallsSpam() {
        action?.on = false

        var executionCompleted = false

        let context = ActionContext(block: utility.mockCommentContent(insertInto: contextManager.mainContext), content: "content") { (request, success) in
            executionCompleted = true
        }

        action?.execute(context: context)

        XCTAssertTrue(executionCompleted)
    }
}
