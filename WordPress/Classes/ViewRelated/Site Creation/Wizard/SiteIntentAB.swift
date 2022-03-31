protocol SiteIntentABTestable {
    var variant: SiteIntentAB.Variant { get }
}

class SiteIntentAB: SiteIntentABTestable {
    static let shared = SiteIntentAB()

    enum Variant {
        case control
        case treatment
    }

    private let accountService: AccountService

    public var variant: Variant {
        calculateVariant()
    }

    private init(accountService: AccountService = AccountService(managedObjectContext: ContextManager.sharedInstance().mainContext)) {
        self.accountService = accountService
    }

    private func calculateVariant() -> Variant {
        let defaultAccount = accountService.defaultWordPressComAccount()
        let token: String? = defaultAccount?.authToken

        if let token = token {
            // 50/50 split between control and treatment groups
            return token.hashCode() % 2 == 0 ? .control : .treatment
        } else {
            return .control
        }
    }
}

private extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars
            .filter { $0.isASCII }
            .map { $0.value }
    }

    func hashCode() -> Int32 {
        var h: Int32 = 0
        for i in self.asciiArray {
            h = 31 &* h &+ Int32(i)
        }
        return h
    }
}
