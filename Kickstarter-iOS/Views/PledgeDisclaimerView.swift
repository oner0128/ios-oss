import Library
import Prelude
import UIKit

protocol PledgeDisclaimerViewDelegate: AnyObject {
  func pledgeDisclaimerView(_ view: PledgeDisclaimerView, didTapURL: URL)
}

final class PledgeDisclaimerView: UIView {
  // MARK: - Properties

  private lazy var iconImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var leftColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var textView: UITextView = { UITextView(frame: .zero) |> \.delegate .~ self }()

  weak var delegate: PledgeDisclaimerViewDelegate?
  private let viewModel: PledgeDisclaimerViewModelType = PledgeDisclaimerViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with data: PledgeDisclaimerViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()

    _ = ([self.leftColumnStackView, self.textView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.iconImageView], self.leftColumnStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self)
      |> ksr_constrainViewToEdgesInParent()

    self.leftColumnStackView.widthAnchor.constraint(equalToConstant: Styles.grid(6)).isActive = true
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_400

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.iconImageView
      |> iconImageViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)

    _ = self.textView
      |> textViewStyle

    _ = self.leftColumnStackView
      |> leftColumnStackViewStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateLinkTappedWithURL
      .observeForUI()
      .observeValues { [weak self] url in
        guard let self = self else { return }
        self.delegate?.pledgeDisclaimerView(self, didTapURL: url)
      }

    self.viewModel.outputs.iconImageName
      .observeForUI()
      .observeValues { [weak self] iconImageName in
        self?.iconImageView.image = Library
          .image(named: iconImageName)?.withRenderingMode(.alwaysTemplate)
      }

    self.viewModel.outputs.attributedText
      .observeForUI()
      .observeValues { [weak self] text in
        self?.textView.attributedText = text
      }
  }
}

extension PledgeDisclaimerView: UITextViewDelegate {
  func textView(
    _: UITextView, shouldInteractWith _: NSTextAttachment,
    in _: NSRange, interaction _: UITextItemInteraction
  ) -> Bool {
    return false
  }

  func textView(
    _: UITextView, shouldInteractWith url: URL, in _: NSRange,
    interaction _: UITextItemInteraction
  ) -> Bool {
    self.viewModel.inputs.linkTapped(url: url)
    return false
  }
}

// MARK: - Styles

private let textViewStyle: TextViewStyle = { (textView: UITextView) -> UITextView in
  textView
    |> tappableLinksViewStyle
    |> \.font .~ UIFont.ksr_caption1()
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.accessibilityTraits .~ [.staticText]
    |> \.backgroundColor .~ .ksr_grey_400
}

private func iconImageViewStyle(_ isAccessibilityCategory: Bool) -> (ImageViewStyle) {
  return { (imageView: UIImageView) in
    imageView
      |> \.tintColor .~ .ksr_green_500
      |> \.contentMode .~ (isAccessibilityCategory ? .top : .center)
  }
}

private let leftColumnStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.gridHalf(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ UIEdgeInsets(topBottom: Styles.grid(2), leftRight: Styles.grid(3))
    |> \.spacing .~ Styles.grid(2)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
