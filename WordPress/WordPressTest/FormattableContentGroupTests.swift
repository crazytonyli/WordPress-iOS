import XCTest
@testable import WordPress

final class FormattableContentGroupTests: XCTestCase {
    private var subject: FormattableContentGroup?

    private struct Constants {
        static let kind: FormattableContentGroup.Kind = .activity
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        subject = FormattableContentGroup(blocks: [try mockContent()], kind: Constants.kind)
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func testKindRemainsAsInitialised() {
        XCTAssertEqual(subject?.kind, Constants.kind)
    }

    func testBlocksRemainAsInitialised() throws {
        let groupBlocks = subject?.blocks as? [FormattableTextContent]
        let mockBlocks = [try mockContent()]

        /// Compare by the blocks' text
        let groupBlocksText = groupBlocks!.map { $0.text }
        let mockBlocksText = mockBlocks.map { $0.text }

        XCTAssertEqual(groupBlocksText, mockBlocksText)
    }

    func testBlockOfKindReturnsExpectation() throws {
        let obtainedBlock: FormattableTextContent? = subject?.blockOfKind(.text)
        let obtainedBlockText = obtainedBlock?.text

        let mockText = try mockContent().text

        XCTAssertEqual(obtainedBlockText, mockText)
    }

    func testBlockOfKindReturnsNilWhenNotFound() {
        let obtainedBlock: FormattableTextContent? = subject?.blockOfKind(.image)

        XCTAssertNil(obtainedBlock)
    }

    private func mockContent() throws -> FormattableTextContent {
        let mockActivity = try Fixture.ActivityContent.activity.jsonObject()
        let text = mockActivity["text"] as? String ?? ""
        return FormattableTextContent(text: text, ranges: [], actions: [])
    }
}
