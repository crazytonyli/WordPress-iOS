import Gridicons

protocol PostEditorNavigationBarManagerDelegate: AnyObject {
    var publishButtonText: String { get }
    var isPublishButtonEnabled: Bool { get }
    var uploadingButtonSize: CGSize { get }
    var savingDraftButtonSize: CGSize { get }

    func navigationBarManager(_ manager: PostEditorNavigationBarManager, closeWasPressed sender: UIButton)
    func navigationBarManager(_ manager: PostEditorNavigationBarManager, moreWasPressed sender: UIButton)
    func navigationBarManager(_ manager: PostEditorNavigationBarManager, publishButtonWasPressed sender: UIButton)
    func navigationBarManager(_ manager: PostEditorNavigationBarManager, displayCancelMediaUploads sender: UIButton)
    func navigationBarManager(_ manager: PostEditorNavigationBarManager, reloadTitleView view: UIView)
}

// A class to share the navigation bar UI of the Post Editor.
// Currenly shared between Aztec and Gutenberg
//
class PostEditorNavigationBarManager {
    weak var delegate: PostEditorNavigationBarManagerDelegate?

    // MARK: - Buttons

    /// Dismiss Button
    ///
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        if #available(iOS 15, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.image = Assets.closeButtonModalImage
            configuration.contentInsets = Constants.closeButtonInsets
            button.configuration = configuration
        } else {
            button.setImage(Assets.closeButtonModalImage, for: .normal)
            button.contentEdgeInsets = Constants.closeButtonEdgeInsets
        }
        button.addTarget(self, action: #selector(closeWasPressed), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.accessibilityIdentifier = "editor-close-button"
        button.tintColor = .editorPrimary
        return button
    }()

    private lazy var moreButton: UIButton = {
        let image = UIImage.gridicon(.ellipsis)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.frame = CGRect(origin: .zero, size: image.size)
        button.accessibilityLabel = NSLocalizedString("More Options", comment: "Action button to display more available options")
        button.accessibilityIdentifier = "more_post_options"
        button.addTarget(self, action: #selector(moreWasPressed), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    /// Blog TitleView Label
    lazy var blogTitleViewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appBarText
        label.font = Fonts.blogTitle
        return label
    }()

    /// Publish Button
    private(set) lazy var publishButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(publishButtonTapped(sender:)), for: .touchUpInside)
        button.setTitle(delegate?.publishButtonText ?? "", for: .normal)
        button.sizeToFit()
        button.isEnabled = delegate?.isPublishButtonEnabled ?? false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.tintColor = .editorPrimary
        return button
    }()

    /// Media Uploading Button
    ///
    private lazy var mediaUploadingButton: WPUploadStatusButton = {
        let button = WPUploadStatusButton(frame: CGRect(origin: .zero, size: delegate?.uploadingButtonSize ?? .zero))
        button.setTitle(NSLocalizedString("Media Uploading", comment: "Message to indicate progress of uploading media to server"), for: .normal)
        button.addTarget(self, action: #selector(displayCancelMediaUploads), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return button
    }()

    /// Preview Generating Button
    ///
    private lazy var previewGeneratingView: LoadingStatusView = {
        let view = LoadingStatusView(title: NSLocalizedString("Generating Preview", comment: "Message to indicate progress of generating preview"))
        return view
    }()

    // MARK: - Bar button items

    /// Negative Offset BarButtonItem: Used to fine tune navigationBar Items
    ///
    internal lazy var separatorButtonItem: UIBarButtonItem = {
        let separator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        return separator
    }()


    /// NavigationBar's Close Button
    ///
    lazy var closeBarButtonItem: UIBarButtonItem = {
        let cancelItem = UIBarButtonItem(customView: self.closeButton)
        cancelItem.accessibilityLabel = NSLocalizedString("Close", comment: "Action button to close edior and cancel changes or insertion of post")
        cancelItem.accessibilityIdentifier = "Close"
        return cancelItem
    }()

    /// Publish Button
    private(set) lazy var publishBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: self.publishButton)

        return button
    }()

    /// NavigationBar's More Button
    ///
    lazy var moreBarButtonItem: UIBarButtonItem = {
        let moreItem = UIBarButtonItem(customView: self.moreButton)
        return moreItem
    }()

    // MARK: - Selectors

    @objc private func closeWasPressed(sender: UIButton) {
        delegate?.navigationBarManager(self, closeWasPressed: sender)
    }

    @objc private func moreWasPressed(sender: UIButton) {
        delegate?.navigationBarManager(self, moreWasPressed: sender)
    }

    @objc private func publishButtonTapped(sender: UIButton) {
        delegate?.navigationBarManager(self, publishButtonWasPressed: sender)
    }

    @objc private func displayCancelMediaUploads(sender: UIButton) {
        delegate?.navigationBarManager(self, displayCancelMediaUploads: sender)
    }

    // MARK: - Public

    var leftBarButtonItems: [UIBarButtonItem] {
        return [separatorButtonItem, closeBarButtonItem]
    }

    var uploadingMediaTitleView: UIView {
        mediaUploadingButton
    }

    var generatingPreviewTitleView: UIView {
        previewGeneratingView
    }

    var rightBarButtonItems: [UIBarButtonItem] {
        return [moreBarButtonItem, publishBarButtonItem, separatorButtonItem]
    }

    func reloadPublishButton() {
        publishButton.setTitle(delegate?.publishButtonText ?? "", for: .normal)
        publishButton.sizeToFit()
        publishButton.isEnabled = delegate?.isPublishButtonEnabled ?? true
    }

    func reloadBlogTitleView(text: String) {
        blogTitleViewLabel.text = text
    }

    func reloadTitleView(_ view: UIView) {
        delegate?.navigationBarManager(self, reloadTitleView: view)
    }
}

extension PostEditorNavigationBarManager {
    private enum Constants {
        static let closeButtonInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        static let closeButtonEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }

    private enum Fonts {
        static let semiBold = WPFontManager.systemSemiBoldFont(ofSize: 16)
        static var blogTitle: UIFont {
            WPStyleGuide.navigationBarStandardFont
        }
    }

    private enum Assets {
        static let closeButtonModalImage    = UIImage.gridicon(.cross)
    }
}
