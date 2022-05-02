import XCTest
@testable import WordPress

final class NotificationsContentFactoryTests: XCTestCase {
    private let contextManager = TestContextManager()
    private let entityName = Notification.classNameWithoutNamespaces()

    func testTextNotificationReturnsExpectedImplementationOfFormattableContent() {
        let subject = NotificationContentFactory.content(
            from: [mockTextContentDictionary()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? NotificationTextContent

        XCTAssertNotNil(subject)
    }

    func testCommentNotificationReturnsExpectedImplementationOfFormattableContent() {
        let subject = NotificationContentFactory.content(
            from: [mockCommentContentDictionary()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? FormattableCommentContent

        XCTAssertNotNil(subject)
    }

    func testUserNotificationReturnsExpectedImplementationOfFormattableContent() {
        let subject = NotificationContentFactory.content(
            from: [mockUserContentDictionary()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? FormattableUserContent

        XCTAssertNotNil(subject)
    }

    private func mockTextContentDictionary() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "notifications-text-content.json")
    }

    private func mockCommentContentDictionary() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "notifications-comment-content.json")
    }

    private func mockUserContentDictionary() -> [String: AnyObject] {
        return getDictionaryFromFile(named: "notifications-user-content.json")
    }

    private func getDictionaryFromFile(named fileName: String) -> [String: AnyObject] {
        return JSONLoader().loadFile(named: fileName) ?? [:]
    }

}
