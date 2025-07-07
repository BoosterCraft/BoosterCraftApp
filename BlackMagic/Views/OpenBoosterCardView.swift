import UIKit

final class OpenBoosterCardView: UIView {

    private let frontView = UIView()
    private let backView = UIView()

    private let setLabel = UILabel()
    private let typeLabel = UILabel()
    private let boosterLabel = UILabel()

    private let badgeLabel = UILabel()  // badge moved to self

    private let backTextLabel = UILabel()

    private var isFrontVisible = true

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = false  // <- allow badge to overflow

        setupFront()
        setupBack()

        addSubview(frontView)
        addSubview(backView)
        addSubview(badgeLabel) // badge added to self, not frontView

        frontView.pin(to: self)
        backView.pin(to: self)
        backView.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        addGestureRecognizer(tap)

        setupBadge()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Views

    private func setupFront() {
        frontView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        frontView.layer.cornerRadius = 16
        frontView.clipsToBounds = true

        [setLabel, typeLabel, boosterLabel].forEach {
            frontView.addSubview($0)
        }

        setLabel.font = UIFont.boldSystemFont(ofSize: 14)
        setLabel.textColor = .white
        setLabel.textAlignment = .center
        setLabel.backgroundColor = .systemBlue
        setLabel.layer.cornerRadius = 8
        setLabel.clipsToBounds = true

        typeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.textAlignment = .center

        boosterLabel.font = UIFont.systemFont(ofSize: 14)
        boosterLabel.textColor = .lightGray
        boosterLabel.textAlignment = .center

        setLabel.pinTop(to: frontView, 8)
        setLabel.pinLeft(to: frontView, 8)
        setLabel.pinRight(to: frontView, 8)
        setLabel.setHeight(24)

        typeLabel.pinTop(to: setLabel.bottomAnchor, 16)
        typeLabel.pinLeft(to: frontView, 8)
        typeLabel.pinRight(to: frontView, 8)

        boosterLabel.pinTop(to: typeLabel.bottomAnchor, 4)
        boosterLabel.pinLeft(to: frontView, 8)
        boosterLabel.pinRight(to: frontView, 8)
    }

    private func setupBack() {
        backView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backView.layer.cornerRadius = 16
        backView.clipsToBounds = true

        backTextLabel.font = UIFont.boldSystemFont(ofSize: 18)
        backTextLabel.textColor = .white
        backTextLabel.numberOfLines = 0
        backTextLabel.textAlignment = .center
        backTextLabel.text = "Back side.\nTap to flip."

        backView.addSubview(backTextLabel)
        backTextLabel.pinCenter(to: backView)
    }

    private func setupBadge() {
        badgeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = .systemBlue
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
        badgeLabel.layer.borderWidth = 2
        badgeLabel.layer.borderColor = UIColor.black.cgColor

        // Size & position: bottom-right overhanging by 8pt
        badgeLabel.setWidth(24)
        badgeLabel.setHeight(24)
        badgeLabel.pinBottom(to: self, -8)
        badgeLabel.pinRight(to: self, -8)
    }

    // MARK: - Public Configuration

    func configure(set: String, type: String, count: Int, color: UIColor) {
        setLabel.text = set
        setLabel.backgroundColor = color
        typeLabel.text = type
        boosterLabel.text = "booster"
        badgeLabel.text = "\(count)"
        badgeLabel.isHidden = (count == 0)
    }

    // MARK: - Flip Animation

    @objc private func flipCard() {
        let fromView = isFrontVisible ? frontView : backView
        let toView = isFrontVisible ? backView : frontView

        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: nil)

        isFrontVisible.toggle()
    }
}
