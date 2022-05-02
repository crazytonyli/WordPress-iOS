
import Foundation
import XCTest
@testable import WordPress

class NotificationUtility {
    var contextManager: TestContextManager!

    func setUp() {
        contextManager = TestContextManager()
    }

    func tearDown() {
        // Note: We'll force TestContextManager override reset, since, for (unknown reasons) the TestContextManager
        // might be retained more than expected, and it may break other core data based tests.
        ContextManager.overrideSharedInstance(nil)
    }

    func mockCommentContent() -> FormattableCommentContent {
        let dictionary = JSONLoader().loadFile(named: "notifications-replied-comment.json") ?? [:]
        let body = dictionary["body"]
        let blocks = NotificationContentFactory.content(from: body as! [[String: AnyObject]], actionsParser: NotificationActionParser(), parent: WordPress.Notification(context: contextManager.mainContext))
        return blocks.filter { $0.kind == .comment }.first! as! FormattableCommentContent
    }

    func mockCommentContext() -> ActionContext<FormattableCommentContent> {
        return ActionContext(block: mockCommentContent())
    }
}

extension Fixtures {
    enum Notification: String, ManagedObjectFixture {
        typealias Model = WordPress.Notification

        case badge = "notifications-badge.json"
        case like = "notifications-like.json"
        case newFollower = "notifications-new-follower.json"
        case repliedComment = "notifications-replied-comment.json"
        case unapprovedComment = "notifications-unapproved-comment.json"
        case pingback = "notifications-pingback.json"
    }

    enum NotificationContent: String, JSONFileFixture {
        case comment = "notifications-comment-content.json"
        case text = "notifications-text-content.json"
        case buttonText = "notifications-button-text-content.json"
        case user = "notifications-user-content.json"
    }
}
