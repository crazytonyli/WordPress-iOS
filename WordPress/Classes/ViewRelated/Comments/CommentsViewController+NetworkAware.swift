import UIKit

extension CommentsViewController: NetworkAwareUI {
    func contentIsEmpty() -> Bool {
        return tableViewHandler.resultsController.isEmpty()
    }

    @objc
    func noConnectionMessage() -> String {
        return ReachabilityUtils.noConnectionMessage()
    }

    @objc
    func connectionAvailable() -> Bool {
        return ReachabilityUtils.isInternetReachable()
    }
}
