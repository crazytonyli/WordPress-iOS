import Foundation
import WordPressKit

@objc final class BlazeService: NSObject {

    private let contextManager: CoreDataStackSwift
    private let remote: BlazeServiceRemote

    // MARK: - Init

    required init?(contextManager: CoreDataStackSwift = ContextManager.shared,
                   remote: BlazeServiceRemote? = nil) {
        guard let account = try? WPAccount.lookupDefaultWordPressComAccount(in: contextManager.mainContext) else {
            return nil
        }

        self.contextManager = contextManager
        self.remote = remote ?? .init(wordPressComRestApi: account.wordPressComRestV2Api)
    }

    @objc class func createService() -> BlazeService? {
        self.init()
    }

    // MARK: - Methods

    func getRecentCampaigns(for blog: Blog,
                            completion: @escaping (Result<BlazeCampaignsSearchResponse, Error>) -> Void) {
        guard let siteId = blog.dotComID?.intValue else {
            DDLogError("Invalid site ID for Blaze")
            completion(.failure(BlazeServiceError.missingBlogId))
            return
        }
        remote.searchCampaigns(forSiteId: siteId, callback: completion)
    }
}

enum BlazeServiceError: Error {
    case missingBlogId
}
