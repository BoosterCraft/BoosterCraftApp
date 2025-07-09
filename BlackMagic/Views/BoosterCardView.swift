import UIKit

class BoosterCardView: UIView {
    
    private let containerView = UIView()
    private let frontView = UIView()
    private let backView = UIView()
    // Front side elements
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buyButton = UIButton(type: .system)
    
    // Back side elements
    private let backTitleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Play", "Collector"])
    private let detailsLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()
    private let priceButton = UIButton(type: .system)
    
    private var isFrontVisible = true

    // Колбэк для покупки бустера
    var onBuyTapped: ((BoosterPurchaseInfo) -> Void)?
    // Код сета для покупки (устанавливается при конфигурировании)
    private var purchaseSetCode: String?

    // MARK: - Init
    
    init(imageURL: URL?,
         title: String,
         description: String,
         titleColor: UIColor,
         titleBackgroundColor: UIColor,
         buttonTextColor: UIColor,
         titleFontSize: Int,
         set: ScryfallSet,
         price: String = "$50")
    {
        super.init(frame: .zero)
        setupViews()
        setupFront(imageURL: imageURL, title: title, description: description, titleColor: titleColor, titleBackgroundColor: titleBackgroundColor, buttonTextColor: buttonTextColor, titleFontSize: titleFontSize)
        setupBack(with: set, price: price)
        showFront()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = UIColor(red: 37, green: 37, blue: 37)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        
        addSubview(containerView)
        
        containerView.pin(to: self)
        frontView.layer.cornerRadius = 20
        backView.layer.cornerRadius = 20
        
        // Shadow setup
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8

        containerView.addSubviews(frontView, backView)
        
        frontView.pin(to: containerView)
        backView.pin(to: containerView)
    }

    private func setupFront(imageURL: URL?, title: String, description: String, titleColor: UIColor, titleBackgroundColor: UIColor, buttonTextColor: UIColor, titleFontSize: Int) {
        
        UIImage.loadFromURL(imageURL) { img in
            self.imageView.image = img
        }
    
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = UIFont(name: "Bungee-Regular", size: CGFloat(titleFontSize))
        titleLabel.textColor = titleColor
        titleLabel.backgroundColor = titleBackgroundColor
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = description
        
        buyButton.setTitle("BUY NOW", for: .normal)
        buyButton.setTitleColor(buttonTextColor, for: .normal)
        buyButton.titleLabel?.font = UIFont(name: "Bungee-Regular", size: 18)
        buyButton.backgroundColor = .white
        buyButton.layer.cornerRadius = 14
        buyButton.addTarget(self, action: #selector(flipCardAnimated), for: .touchUpInside)
        
        frontView.addSubviews(imageView, titleLabel, descriptionLabel, buyButton)

        imageView.pinTop(to: frontView, 0)
        imageView.pinLeft(to: frontView, 0)
        imageView.pinRight(to: frontView, 0)
        imageView.setHeight(mode: .equal, 200)

        titleLabel.pinTop(to: imageView.bottomAnchor, 0)
        titleLabel.pinLeft(to: frontView)
        titleLabel.pinRight(to: frontView)
        titleLabel.setHeight(mode: .equal, 36)

        descriptionLabel.pinTop(to: titleLabel.bottomAnchor, 12)
        descriptionLabel.pinLeft(to: frontView, 16)
        descriptionLabel.pinRight(to: frontView, 16)

        buyButton.pinTop(to: descriptionLabel.bottomAnchor, 8)
        buyButton.pinLeft(to: frontView, 16)
        buyButton.pinRight(to: frontView, 16)
        buyButton.setHeight(mode: .equal, 50)
        buyButton.pinBottom(to: frontView, 16)
    }


    private func setupBack(with set: ScryfallSet, price: String) {
        backTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        backTitleLabel.textColor = .white
        backTitleLabel.textAlignment = .center
        backTitleLabel.text = set.name
        
        segmentedControl.selectedSegmentIndex = 0
        
        detailsLabel.font = UIFont.systemFont(ofSize: 16)
        detailsLabel.textColor = .white
        detailsLabel.numberOfLines = 0
        detailsLabel.text = "Код: \(set.code)\nТип: \(set.set_type)\nКарт: \(set.card_count)\nДата релиза: \(set.released_at)"
        
        quantityStepper.minimumValue = 1
        quantityStepper.maximumValue = 10
        quantityStepper.value = 1
        quantityStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        
        quantityLabel.font = UIFont.boldSystemFont(ofSize: 18)
        quantityLabel.textColor = .white
        quantityLabel.text = "1"
        quantityLabel.textAlignment = .center
        
        priceButton.setTitle("Buy for \(price)", for: .normal)
        priceButton.setTitleColor(.white, for: .normal)
        priceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        priceButton.backgroundColor = .systemBlue
        priceButton.layer.cornerRadius = 14
        priceButton.addTarget(self, action: #selector(handleBuyTapped), for: .touchUpInside)
        
        backView.addSubviews(backTitleLabel, segmentedControl, detailsLabel, quantityStepper, quantityLabel, priceButton)
        
        backTitleLabel.pinTop(to: backView, 16)
        backTitleLabel.pinLeft(to: backView, 16)
        backTitleLabel.pinRight(to: backView, 16)
        
        segmentedControl.pinTop(to: backTitleLabel.bottomAnchor, 16)
        segmentedControl.pinLeft(to: backView, 16)
        segmentedControl.pinRight(to: backView, 16)
        
        detailsLabel.pinTop(to: segmentedControl.bottomAnchor, 16)
        detailsLabel.pinLeft(to: backView, 16)
        detailsLabel.pinRight(to: backView, 16)
        
        quantityStepper.pinTop(to: detailsLabel.bottomAnchor, 16)
        quantityStepper.pinLeft(to: backView, 32)
        
        quantityLabel.pinCenterY(to: quantityStepper)
        quantityLabel.pinLeft(to: quantityStepper.trailingAnchor, 12)
        quantityLabel.setWidth(mode: .equal, 30)
        
        priceButton.pinTop(to: quantityStepper.bottomAnchor, 24)
        priceButton.pinLeft(to: backView, 16)
        priceButton.pinRight(to: backView, 16)
        priceButton.setHeight(mode: .equal, 50)
        priceButton.pinBottom(to: backView, 16)
        
        // Tap to flip back
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCardAnimated))
        backView.addGestureRecognizer(tapGesture)
    }

    private func showFront() {
        containerView.bringSubviewToFront(frontView)
        backView.isHidden = true
        frontView.isHidden = false
        isFrontVisible = true
    }


    // MARK: - Actions
    
    @objc private func flipCardAnimated() {
        let fromView = isFrontVisible ? frontView : backView
        let toView = isFrontVisible ? backView : frontView

        toView.isHidden = false // ensure destination is visible before animating
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews]) { _ in
            fromView.isHidden = true
        }

        isFrontVisible.toggle()
    }

    
    @objc private func stepperChanged() {
        quantityLabel.text = "\(Int(quantityStepper.value))"
        // Обновляем цену на кнопке
        let price = Int(quantityStepper.value) * 50
        priceButton.setTitle("Buy for $\(price)", for: .normal)
    }

    // Метод для конфигурирования кода сета
    func configurePurchase(setCode: String) {
        self.purchaseSetCode = setCode
    }

    // Обработка нажатия на BUY
    @objc private func handleBuyTapped() {
        guard let setCode = purchaseSetCode else { return }
        let type: UserBooster.BoosterType = segmentedControl.selectedSegmentIndex == 0 ? .play : .collector
        let quantity = Int(quantityStepper.value)
        let color = backTitleLabel.backgroundColor // Можно заменить на нужный цвет
        let info = BoosterPurchaseInfo(setCode: setCode, type: type, quantity: quantity, color: color)
        onBuyTapped?(info)
    }
}

extension UIImage {
    
    /// Общий in-memory кэш изображений
    private static let imageCache = NSCache<NSURL, UIImage>()

    /// Загружает картинку по URL с кешированием. При повторных вызовах загрузка не происходит.
    /// - Parameters:
    ///   - url: Опциональный URL
    ///   - completion: Вызывается с изображением (или серым placeholder'ом)
    static func loadFromURL(_ url: URL?, completion: @escaping (UIImage) -> Void) {
        
        // Проверка наличия URL
        guard let url = url else {
            print("❌ loadFromURL: URL is nil. Возвращается placeholder.")
            completion(grayPlaceholder())
            return
        }
        
        // Проверка наличия изображения в кеше
        if let cached = imageCache.object(forKey: url as NSURL) {
            print("✅ loadFromURL: Изображение найдено в кеше для \(url.absoluteString)")
            completion(cached)
            return
        }
        
        // Если нет в кеше — загружаем
        print("⬇️ loadFromURL: Загружаем изображение с сети: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                // Сохраняем в кеш
                imageCache.setObject(image, forKey: url as NSURL)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("❌ loadFromURL: Ошибка загрузки изображения с \(url.absoluteString). Причина: \(error?.localizedDescription ?? "неизвестно")")
                DispatchQueue.main.async {
                    completion(grayPlaceholder())
                }
            }
        }.resume()
    }

    /// Серое изображение-заглушка, если не удалось загрузить с URL
    private static func grayPlaceholder(size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// Информация о покупке бустера
struct BoosterPurchaseInfo {
    let setCode: String
    let type: UserBooster.BoosterType
    let quantity: Int
    let color: UIColor?
}


