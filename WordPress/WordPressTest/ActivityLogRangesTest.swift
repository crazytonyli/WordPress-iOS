import XCTest
@testable import WordPress

final class ActivityLogRangesTests: XCTestCase {

    let testData = ActivityLogTestData()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPostRangeCreatesURL() {
        let range = NSRange(location: 0, length: 0)
        let postRange = ActivityPostRange(range: range, siteID: testData.testSiteID, postID: testData.testPostID)

        XCTAssertEqual(testData.testPostUrl, postRange.url?.absoluteString)
    }

    func testPluginRangeCreatesURL() {
        let range = NSRange(location: 0, length: 0)
        let pluginRange = ActivityPluginRange(range: range, pluginSlug: testData.testPluginSlug, siteSlug: testData.testSiteSlug)

        XCTAssertEqual(pluginRange.url?.absoluteString, testData.testPluginUrl)
    }

    func testPluginRangeSavesSlugs() {
        let range = NSRange(location: 0, length: 0)
        let pluginRange = ActivityPluginRange(range: range, pluginSlug: testData.testPluginSlug, siteSlug: testData.testSiteSlug)

        XCTAssertEqual(pluginRange.pluginSlug, testData.testPluginSlug)
        XCTAssertEqual(pluginRange.siteSlug, testData.testSiteSlug)
    }

    func testDefaultRange() {
        let range = NSRange(location: 0, length: 0)
        let url = URL(string: testData.testPostUrl)!

        let defaultRange = ActivityRange(range: range, url: url)

        XCTAssertEqual(defaultRange.kind, .default)
        XCTAssertEqual(defaultRange.url?.absoluteString, testData.testPostUrl)
        XCTAssertEqual(defaultRange.range, range)
    }

    func testRangeFactoryCreatesCommentRange() throws {
        let range = try Fixture.Activity.commentContent.range()

        XCTAssertNotNil(range)
        XCTAssertTrue(range is ActivityCommentRange)

        let commentRange = range as? ActivityCommentRange

        XCTAssertEqual(commentRange?.kind, .comment)
        XCTAssertNotNil(commentRange?.url)
    }

    func testRangeFactoryCreatesThemeRange() throws {
        let range = try Fixture.Activity.themeContent.range()

        XCTAssertNotNil(range)
        XCTAssertTrue(range is ActivityRange)

        let themeRange = range as? ActivityRange

        XCTAssertEqual(themeRange?.kind, .theme)
        XCTAssertNotNil(themeRange?.url)
    }

    func testRangeFactoryCreatesPostRange() throws {
        let range = try Fixture.Activity.postContent.range()
        XCTAssertNotNil(range)
        XCTAssertEqual(range?.kind, .post)
        XCTAssertTrue(range is ActivityPostRange)

        let postRange = range as? ActivityPostRange

        XCTAssertEqual(postRange?.url?.absoluteString, testData.testPostUrl)
    }

    func testRangeFactoryCreatesItalicRange() throws {
        let range = try Fixture.Activity.settingsContent.range()
        XCTAssertNotNil(range)
        XCTAssertEqual(range?.kind, .italic)
    }

    func testRangeFactoryCreatesSiteRange() throws {
        let range = try Fixture.Activity.siteContent.range()

        XCTAssertNotNil(range)
        XCTAssertEqual(range?.kind, .site)
    }

    func testRangeFactoryCreatesPluginRange() throws {
        let range = try Fixture.Activity.pluginContent.range()

        XCTAssertNotNil(range)
        XCTAssertEqual(range?.kind, .plugin)
        XCTAssertTrue(range is ActivityPluginRange)

        let pluginRange = range as? ActivityPluginRange

        XCTAssertEqual(pluginRange?.url?.absoluteString, testData.testPluginUrl)
    }
}
