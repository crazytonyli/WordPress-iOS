
import Foundation
import CoreData
import XCTest
@testable import WordPress

extension WordPress.Notification {

    enum Fixture: String {
        case badge = "notifications-badge.json"
        case like = "notifications-like.json"
        case newFollower = "notifications-new-follower.json"
        case repliedComment = "notifications-replied-comment.json"
        case unapprovedComment = "notifications-unapproved-comment.json"
        case pingback = "notifications-pingback.json"
    }

    static func fixture(_ fixture: Fixture, insertInto context: NSManagedObjectContext) -> WordPress.Notification {
        return .fixture(fromFile: fixture.rawValue, context: context)
    }

}

class NotificationUtility {
    func mockCommentContent(insertInto context: NSManagedObjectContext) -> FormattableCommentContent {
        let dictionary = JSONLoader().loadFile(named: "notifications-replied-comment.json") ?? [:]
        let body = dictionary["body"]
        let blocks = NotificationContentFactory.content(from: body as! [[String: AnyObject]], actionsParser: NotificationActionParser(), parent: WordPress.Notification(context: context))
        return blocks.filter { $0.kind == .comment }.first! as! FormattableCommentContent
    }

    func mockCommentContext(insertInto context: NSManagedObjectContext) -> ActionContext<FormattableCommentContent> {
        return ActionContext(block: mockCommentContent(insertInto: context))
    }
}
