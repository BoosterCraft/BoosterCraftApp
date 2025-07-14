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
    private let backStack = UIStackView() // стек для адаптивного размещения

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

    func configure(with card: Card, showBadge: Bool = true, onImageLoadFailed: (() -> Void)? = nil) {
        if let url = card.image_url {
            ScryfallServiceManager.shared.loadCardImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    if let img = image {
                        self?.cardImageView.image = img
                    } else {
                        self?.cardImageView.image = UIImage(named: card.name)
                        // Если не удалось загрузить изображение — вызываем callback для замены карты
                        onImageLoadFailed?()
                    }
                }
            }
        } else {
            cardImageView.image = UIImage(named: card.name)
            // Если нет image_url — тоже можно вызвать onImageLoadFailed
            onImageLoadFailed?()
        }
        badgeCount = card.count
        sellCount = 1
        if let priceString = card.price_usd, let price = Double(priceString) {
            priceLabel.text = String(format: "$%.2f", price)
        } else {
            priceLabel.text = ""
        }
        badgeView.isHidden = !showBadge || badgeCount == 0
        badgeLabel.text = "\(badgeCount)"
        // Устанавливаем цвет бейджа по редкости карты
        badgeView.backgroundColor = UIColor.badgeColor(forRarity: card.rarity)
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

    // Создание снапшота с возможностью скрыть цену и бейдж
    func snapshotView(hidePriceAndBadge: Bool) -> UIView? {
        // Сохраняем текущее состояние
        let oldPriceHidden = priceLabel.isHidden
        let oldBadgeHidden = badgeView.isHidden
        // Скрываем элементы, если нужно
        if hidePriceAndBadge {
            priceLabel.isHidden = true
            badgeView.isHidden = true
        }
        // Создаем снапшот
        let snapshot = self.snapshotView(afterScreenUpdates: true)
        // Возвращаем элементы в исходное состояние
        priceLabel.isHidden = oldPriceHidden
        badgeView.isHidden = oldBadgeHidden
        return snapshot
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

        // --- Стилизация степпера для лучшей видимости ---
        let stepperBgColor = UIColor(white: 0.18, alpha: 1)
//        let stepperBorderColor = UIColor.white.cgColor
        let stepperCornerRadius: CGFloat = 8
//        let stepperBorderWidth: CGFloat = 1.5
        
        stepperStack.backgroundColor = stepperBgColor
        stepperStack.layer.cornerRadius = stepperCornerRadius
//        stepperStack.layer.borderColor = stepperBorderColor
//        stepperStack.layer.borderWidth = stepperBorderWidth
        stepperStack.clipsToBounds = true
        
        // Кастомные изображения для минус/плюс (белые)
        let minusImg = UIImage.textSymbol("-", font: .systemFont(ofSize: 26, weight: .bold), color: .white)
        let plusImg = UIImage.textSymbol("+", font: .systemFont(ofSize: 26, weight: .bold), color: .white)
        minusButton.setImage(minusImg, for: .normal)
        minusButton.setTitle(nil, for: .normal)
        plusButton.setImage(plusImg, for: .normal)
        plusButton.setTitle(nil, for: .normal)

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

        // --- Новый стек для адаптивного размещения на обороте ---
        backStack.axis = .vertical
        backStack.spacing = 12
        backStack.distribution = .fill
        backStack.alignment = .fill
        backStack.addArrangedSubview(stepperStack)
        backStack.addArrangedSubview(sellButton)
        backStack.addArrangedSubview(cancelButton)
        backContentView.addSubview(backStack)
        backStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backStack.topAnchor.constraint(equalTo: backContentView.topAnchor, constant: 16),
            backStack.leftAnchor.constraint(equalTo: backContentView.leftAnchor, constant: 12),
            backStack.rightAnchor.constraint(equalTo: backContentView.rightAnchor, constant: -12),
            backStack.bottomAnchor.constraint(lessThanOrEqualTo: backContentView.bottomAnchor, constant: -12)
        ])
        // ---

        frontViewSetup()
    }

    private func frontViewSetup() {
        contentView.addSubviews(imageContainerView, priceLabel, badgeView)

        imageContainerView.addSubviews(cardImageView, backContentView)
        // backContentView.addSubviews(stepperStack, sellButton, cancelButton) // больше не нужно, теперь через backStack

        // Layout image container
        imageContainerView.pinTop(to: contentView)
        imageContainerView.pinLeft(to: contentView)
        imageContainerView.pinRight(to: contentView)
        // imageContainerView.setHeight(155) // Удалено для устранения конфликтов

        cardImageView.pin(to: imageContainerView)
        backContentView.pin(to: imageContainerView)

        priceLabel.pinTop(to: imageContainerView.bottomAnchor, 3)
        priceLabel.pinLeft(to: contentView)
        priceLabel.pinRight(to: contentView)
        priceLabel.pinBottom(to: contentView)

        // Бейдж теперь чуть выходит за пределы карточки в правом верхнем углу (через pin)
        badgeView.pinTop(to: contentView, -8)
        badgeView.pinRight(to: contentView, -8)
        badgeView.setWidth(24)
        badgeView.setHeight(24)
    }
}

// --- Вспомогательное расширение для создания изображения из текста ---
extension UIImage {
    static func textSymbol(_ text: String, font: UIFont, color: UIColor) -> UIImage? {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let rect = CGRect(origin: .zero, size: size)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        let textRect = CGRect(x: 0, y: (size.height-font.lineHeight)/2, width: size.width, height: font.lineHeight)
        text.draw(in: textRect, withAttributes: attrs)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
