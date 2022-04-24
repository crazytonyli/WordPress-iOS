import XCTest

class BlogVideoLimitsTests: XCTestCase {

    private var blog: Blog!
    private var contextManager: ContextManagerMock!
    private var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        contextManager = ContextManagerMock()
        context = contextManager.newDerivedContext()
        blog = NSEntityDescription.insertNewObject(forEntityName: "Blog", into: context) as? Blog
        blog.url = Constants.blogURL
        blog.xmlrpc = Constants.blogURL
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        blog = nil
    }

    func testCanUploadAssetPaidPlan() throws {
        // Given a blog
        // When blog has a paid plan
        blog.hasPaidPlan = true

        // Then it can upload assets irrespective of allowance
        XCTAssertTrue(blog.canUploadAsset(true))
        XCTAssertTrue(blog.canUploadAsset(false))
    }

    func testCanUploadAssetWPCom() throws {
        // Given a blog
        // When blog is on WPCom and not paid
        blog.isHostedAtWPcom = true
        blog.hasPaidPlan = false

        // Then it can upload assets when allowance not exceeded
        XCTAssertTrue(blog.canUploadAsset(false))

        // Then it cannot upload assets when allowance exceeded
        XCTAssertFalse(blog.canUploadAsset(true))
    }

    func testCanUploadAssetSelfHosted() throws {
        // Given a blog
        // When blog is not on WPCom and not paid
        blog.isHostedAtWPcom = false
        blog.hasPaidPlan = false

        // Then it can upload assets irrespective of allowance
        XCTAssertTrue(blog.canUploadAsset(true))
        XCTAssertTrue(blog.canUploadAsset(false))
    }
}

private extension BlogVideoLimitsTests {
    enum Constants {
        static let blogURL: String = "http://wordpress.com"
    }
}
