@testable import WordPress
import CoreData

extension Fixture {
    enum Activity: String, FixtureFile {
        case commentEvent = "activity-log-comment.json"
        case postEvent = "activity-log-post.json"
        case pingback = "activity-log-pingback-content.json"
        case postContent = "activity-log-post-content.json"
        case commentContent = "activity-log-comment-content.json"
        case themeContent = "activity-log-theme-content.json"
        case settingsContent = "activity-log-settings-content.json"
        case siteContent = "activity-log-site-content.json"
        case pluginContent = "activity-log-plugin-content.json"

        func range() throws -> FormattableContentRange? {
            let ranges = try jsonObject()["ranges"] as! [JSONLoader.JSONDictionary]
            return ActivityRangesFactory.contentRange(from: ranges[0])
        }
    }
}

extension Activity {

    static func fixture(_ activity: Fixture.Activity) throws -> Activity {
        return try Activity(dictionary: activity.jsonObject())
    }

}

extension ActivityRange {

    static func fixture(_ fixture: Fixture.Activity) throws -> FormattableContentRange? {
        let ranges = try fixture.jsonObject()["ranges"] as! [JSONLoader.JSONDictionary]
        return ActivityRangesFactory.contentRange(from: ranges[0])
    }

}

class ActivityLogTestData {

    let testPostID = 441
    let testSiteID = 137726971

    let pingbackText = "Pingback to Camino a Machu Picchu from Tren de Machu Picchu a Cusco – eToledo"
    let postText = "Tren de Machu Picchu a Cusco"
    let commentText = "Comment by levitoledo on Hola Lima! 🇵🇪: Great post! True talent!"
    let themeText = "Spatial"
    let settingsText = "Default post category changed from \"subcategory\" to \"viajes\""
    let siteText = "Atomic"
    let pluginText = "WP Job Manager 1.31.1"

    let testPluginSlug = "wp-job-manager"
    let testSiteSlug = "etoledomatomicsite01.blog"

    var testPostUrl: String {
        return "https://wordpress.com/read/blogs/\(testSiteID)/posts/\(testPostID)"
    }
    var testPluginUrl: String {
        return "https://wordpress.com/plugins/\(testPluginSlug)/\(testSiteSlug)"
    }

    var testCommentURL: String {
        return "https://wordpress.com/comment/137726971/7"
    }

}
