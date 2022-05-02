import XCTest
@testable import WordPress

final class ActivityContentFactoryTests: XCTestCase {
    func testActivityContentFactoryReturnsExpectedImplementationOfFormattableContent() throws {
        let subject = ActivityContentFactory.content(
            from: [try Fixture.ActivityContent.activity.jsonObject()],
            actionsParser: ActivityActionsParser()
        ).first as? FormattableTextContent

        XCTAssertNotNil(subject)
    }
}
