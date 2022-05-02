import XCTest
@testable import WordPress

final class NotificationsContentFactoryTests: XCTestCase {
    private let contextManager = TestContextManager()
    private let entityName = Notification.classNameWithoutNamespaces()

    func testTextNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixtures.NotificationContent.text.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: try Fixtures.Notification.like.insertInto(contextManager.mainContext)
        ).first as? NotificationTextContent

        XCTAssertNotNil(subject)
    }

    func testCommentNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixtures.NotificationContent.comment.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: try Fixtures.Notification.like.insertInto(contextManager.mainContext)
        ).first as? FormattableCommentContent

        XCTAssertNotNil(subject)
    }

    func testUserNotificationReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = NotificationContentFactory.content(
            from: [try Fixtures.NotificationContent.user.jsonObject()],
            actionsParser: NotificationActionParser(),
            parent: try Fixtures.Notification.like.insertInto(contextManager.mainContext)
        ).first as? FormattableUserContent

        XCTAssertNotNil(subject)
    }

}
