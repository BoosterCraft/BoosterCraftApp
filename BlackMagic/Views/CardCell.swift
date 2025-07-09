//
//  CardCell.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//

import UIKit

final class CardCell: UICollectionViewCell {
    static let identifier = "CardCell"

    var onSell: ((Int) -> Void)?

    private let imageContainerView = UIView()
    private let cardImageView = UIImageView()
    private let backContentView = UIView()

    private let priceLabel = UILabel()
    private let badgeView = UIView()
    private let badgeLabel = UILabel()

    private let sellButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let stepperStack = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)

    private var badgeCount = 0
    private var sellCount = 1
    private(set) var isFlipped = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        flip(toBack: false, animated: false)
        sellCount = 1
        updateSellTitle()
    }

    func configure(with card: Card) {
        // TODO: если появится image_url, можно добавить асинхронную загрузку
        cardImageView.image = UIImage(named: card.name) // временно используем name как imageName
        badgeCount = card.count
        sellCount = 1
        if let priceString = card.price_usd, let price = Double(priceString) {
            priceLabel.text = String(format: "$%.2f", price)
        } else {
            priceLabel.text = ""
        }
        badgeView.isHidden = badgeCount == 0
        badgeLabel.text = "\(badgeCount)"
        updateSellTitle()
    }

    func flip(toBack: Bool = true, animated: Bool = true) {
        guard isFlipped != toBack else { return }

        isFlipped = toBack
        let fromView = isFlipped ? cardImageView : backContentView
        let toView = isFlipped ? backContentView : cardImageView

        let options: UIView.AnimationOptions = isFlipped ? .transitionFlipFromRight : .transitionFlipFromLeft

        if animated {
            UIView.transition(from: fromView,
                              to: toView,
                              duration: 0.4,
                              options: [options, .showHideTransitionViews])
        } else {
            fromView.isHidden = true
            toView.isHidden = false
        }
    }

    @objc private func sellTapped() {
        onSell?(sellCount)
        flip(toBack: false)
    }

    @objc private func cancelTapped() {
        flip(toBack: false)
    }

    @objc private func stepperAction(_ sender: UIButton) {
        if sender == plusButton, sellCount < badgeCount {
            sellCount += 1
        } else if sender == minusButton, sellCount > 1 {
            sellCount -= 1
        }
        updateSellTitle()
    }

    private func updateSellTitle() {
        sellButton.setTitle("Sell \(sellCount)", for: .normal)
    }

    private func configureUI() {
        contentView.clipsToBounds = false
        imageContainerView.clipsToBounds = false
        cardImageView.clipsToBounds = true
        cardImageView.layer.cornerRadius = 8
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.backgroundColor = .darkGray

        backContentView.isHidden = true
        backContentView.layer.cornerRadius = 8
        backContentView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        backContentView.clipsToBounds = true

        priceLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.textColor = .systemBlue
        priceLabel.textAlignment = .center
        priceLabel.setHeight(22)

        badgeView.backgroundColor = .systemBlue
        badgeView.layer.cornerRadius = 12
        badgeView.setWidth(24)
        badgeView.setHeight(24)

        badgeLabel.font = .boldSystemFont(ofSize: 14)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeView.addSubview(badgeLabel)
        badgeLabel.pinCenter(to: badgeView)

        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 26)
        minusButton.setTitleColor(.white, for: .normal)
        minusButton.addTarget(self, action: #selector(stepperAction(_:)), for: .touchUpInside)

        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 26)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.addTarget(self, action: #selector(stepperAction(_:)), for: .touchUpInside)

        stepperStack.axis = .horizontal
        stepperStack.distribution = .fillEqually
        stepperStack.spacing = 16
        stepperStack.addArrangedSubview(minusButton)
        stepperStack.addArrangedSubview(plusButton)

        sellButton.setTitleColor(.white, for: .normal)
        sellButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        sellButton.backgroundColor = .systemBlue
        sellButton.layer.cornerRadius = 16
        sellButton.setTitle("Sell 1", for: .normal)
        sellButton.addTarget(self, action: #selector(sellTapped), for: .touchUpInside)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        frontViewSetup()
    }

    private func frontViewSetup() {
        contentView.addSubviews(imageContainerView, priceLabel, badgeView)

        imageContainerView.addSubviews(cardImageView, backContentView)
        backContentView.addSubviews(stepperStack, sellButton, cancelButton)

        // Layout image container
        imageContainerView.pinTop(to: contentView)
        imageContainerView.pinLeft(to: contentView)
        imageContainerView.pinRight(to: contentView)
        imageContainerView.setHeight(155)

        cardImageView.pin(to: imageContainerView)
        backContentView.pin(to: imageContainerView)

        priceLabel.pinTop(to: imageContainerView.bottomAnchor)
        priceLabel.pinLeft(to: contentView)
        priceLabel.pinRight(to: contentView)
        priceLabel.pinBottom(to: contentView)

        badgeView.pinTop(to: cardImageView.topAnchor, -12)
        badgeView.pinRight(to: cardImageView.trailingAnchor, -12)

        stepperStack.pinTop(to: backContentView, 12)
        stepperStack.pinLeft(to: backContentView, 12)
        stepperStack.pinRight(to: backContentView, 12)
        stepperStack.setHeight(40)

        sellButton.pinTop(to: stepperStack.bottomAnchor, 12)
        sellButton.pinLeft(to: backContentView, 12)
        sellButton.pinRight(to: backContentView, 12)
        sellButton.setHeight(44)

        cancelButton.pinBottom(to: backContentView, 12)
        cancelButton.pinCenterX(to: backContentView)
    }
}
