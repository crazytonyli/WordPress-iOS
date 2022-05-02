import XCTest
@testable import WordPress

final class NotificationsContentFactoryTests: XCTestCase {
    private let contextManager = TestContextManager()
    private let entityName = Notification.classNameWithoutNamespaces()

    func testTextNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixture.NotificationContent.text.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? NotificationTextContent

        XCTAssertNotNil(subject)
    }

    func testCommentNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixture.NotificationContent.comment.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? FormattableCommentContent

        XCTAssertNotNil(subject)
    }

    func testUserNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixture.NotificationContent.user.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: WordPress.Notification.fixture(.like, insertInto: contextManager.mainContext)
        ).first as? FormattableUserContent

        XCTAssertNotNil(subject)
    }

}
