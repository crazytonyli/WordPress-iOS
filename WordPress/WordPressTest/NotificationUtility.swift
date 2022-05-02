
import Foundation
import CoreData
import XCTest
@testable import WordPress

extension Fixture {
    enum Notification: String, FixtureFile {
        case badge = "notifications-badge.json"
        case like = "notifications-like.json"
        case newFollower = "notifications-new-follower.json"
        case repliedComment = "notifications-replied-comment.json"
        case unapprovedComment = "notifications-unapproved-comment.json"
        case pingback = "notifications-pingback.json"
    }

    enum NotificationContent: String, FixtureFile {
        case comment = "notifications-comment-content.json"
        case text = "notifications-text-content.json"
        case buttonText = "notifications-button-text-content.json"
        case user = "notifications-user-content.json"
    }
}

extension WordPress.Notification {

    static func fixture(_ fixture: Fixture.Notification, insertInto context: NSManagedObjectContext) throws -> WordPress.Notification {
        return try .fixture(fromFile: fixture.fileName, insertInto: context)
    }

}

class NotificationUtility {
    func mockCommentContent(insertInto context: NSManagedObjectContext) throws -> FormattableCommentContent {
        let dictionary = try Fixture.Notification.repliedComment.jsonObject()
        let body = dictionary["body"]
        let blocks = NotificationContentFactory.content(from: body as! [[String: AnyObject]], actionsParser: NotificationActionParser(), parent: WordPress.Notification(context: context))
        return blocks.filter { $0.kind == .comment }.first! as! FormattableCommentContent
    }

    func mockCommentContext(insertInto context: NSManagedObjectContext) throws -> ActionContext<FormattableCommentContent> {
        return ActionContext(block: try mockCommentContent(insertInto: context))
    }
}
