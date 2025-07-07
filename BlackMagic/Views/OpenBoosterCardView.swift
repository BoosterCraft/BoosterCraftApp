import UIKit

final class OpenBoosterCardView: UIView {

    private let setLabel = UILabel()
    private let typeLabel = UILabel()
    private let boosterLabel = UILabel()
    private let countCircle = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        backgroundColor = UIColor(white: 0.15, alpha: 1)

        setupSubviews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure View

    private func setupSubviews() {
        [setLabel, typeLabel, boosterLabel, countCircle].forEach {
            addSubview($0)
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

        countCircle.font = UIFont.boldSystemFont(ofSize: 16)
        countCircle.textColor = .white
        countCircle.textAlignment = .center
        countCircle.backgroundColor = .systemBlue
        countCircle.layer.cornerRadius = 16
        countCircle.clipsToBounds = true
    }

    private func setupLayout() {
        setLabel.pinTop(to: self, 8)
        setLabel.pinLeft(to: self, 8)
        setLabel.pinRight(to: self, 8)
        setLabel.setHeight(24)

        typeLabel.pinTop(to: setLabel.bottomAnchor, 16)
        typeLabel.pinLeft(to: self, 8)
        typeLabel.pinRight(to: self, 8)

        boosterLabel.pinTop(to: typeLabel.bottomAnchor, 4)
        boosterLabel.pinLeft(to: self, 8)
        boosterLabel.pinRight(to: self, 8)

        countCircle.pinBottom(to: self, 12)
        countCircle.pinCenterX(to: self)
        countCircle.setWidth(32)
        countCircle.setHeight(32)
    }

    // MARK: - Public Configuration

    func configure(set: String, type: String, count: Int, color: UIColor) {
        setLabel.text = set
        setLabel.backgroundColor = color
        typeLabel.text = type
        boosterLabel.text = "booster"
        countCircle.text = "\(count)"
    }
}
