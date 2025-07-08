import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    private var boosterCardsData: [(title: String, description: String, imageURL: URL?, titleColor: UIColor, titleBackgroundColor: UIColor, buttonTextColor: UIColor, titleFontSize: Int, backData: BoosterBackData)] = []
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Black magic"
        label.font = UIFont(name: "PirataOne-Regular", size: 40)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let balanceButton = BalanceButton()
    
    private lazy var boosterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cardWidth = view.frame.width * 0.75
        let cardHeight = view.frame.height * 0.52
        
        let inset = (view.frame.width - cardWidth) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: cardWidth, height: cardHeight)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BoosterCardCell.self, forCellWithReuseIdentifier: BoosterCardCell.cellId)
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .darkGray
        return pc
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Для теста: устанавливаем баланс пользователя в 500 монет
        let testBalance = UserBalance(coins: 500)
        UserDataManager.shared.saveBalance(testBalance)
        balanceButton.updateBalance()
        setupLayout()
        setupCardData()
        setupPageControl()
        // Test ScryfallServiceManager: Fetch a card by name and print result
        ScryfallServiceManager.shared.fetchCard(named: "Black Lotus") { result in
            switch result {
            case .success(let card):
                print("Fetched card: \(card)")
            case .failure(let error):
                print("Failed to fetch card: \(error)")
            }
        }
        // Тест: Получить 5 последних сетов-экспансий и вывести их в консоль
        ScryfallServiceManager.shared.fetchLatestExpansions { result in
            switch result {
            case .success(let sets):
                print("Последние 5 сетов-экспансий:")
                for set in sets {
                    print(set)
                }
            case .failure(let error):
                print("Ошибка при получении сетов: \(error)")
            }
        }
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubviews(titleLabel, balanceButton, boosterCollectionView, pageControl)
        
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(to: view)
        
        balanceButton.pinTop(to: titleLabel.bottomAnchor, 16)
        balanceButton.pinCenterX(to: view)
        
        boosterCollectionView.pinTop(to: balanceButton.bottomAnchor, 40)
        boosterCollectionView.pinLeft(to: view)
        boosterCollectionView.pinRight(to: view)
        boosterCollectionView.pinHeight(to: view.heightAnchor, 0.52)   // Increased height
        
        // PageControl positioned with some spacing below collectionView to avoid overlap
        pageControl.pinTop(to: boosterCollectionView.bottomAnchor, 48)
        pageControl.pinCenterX(to: view)
    }
    
    private func setupCardData() {
        boosterCardsData = [
            (
                title: "Final Fantasy".uppercased(),
                description: "Cast powerful spells, call upon classic summons, and even visit your favorite locations on the back of a chocobo.",
                imageURL: URL(string: "https://raw.githubusercontent.com/ReSpringLover/imges/refs/heads/main/Final_Fantasy.png") ,
                titleColor: UIColor(red: 28, green: 28, blue: 28),
                titleBackgroundColor: UIColor(red: 255, green: 255, blue: 255),
                buttonTextColor:UIColor(red: 28, green: 28, blue: 28),
                titleFontSize: 20,
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$6.51"
                )
            ),
            (
                title: "Tarkir: dragonstorm".uppercased(),
                description: "Cinematic action, dynamic clan gameplay, and powerful new dragons that add lasting firepower to your collection.",
                imageURL: URL(string: "https://raw.githubusercontent.com/ReSpringLover/imges/refs/heads/main/Tarkir_dragonstorm.png") ,
                titleColor: UIColor(red: 28, green: 28, blue: 28),
                titleBackgroundColor: UIColor(red: 219, green: 240, blue: 252),
                buttonTextColor:UIColor(red: 28, green: 28, blue: 28),
                titleFontSize: 20,
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$6.51"
                )
            ),
            (
                title: "AETHERDRIFT".uppercased(),
                description: "Leave your competition in the dust! Get behind the wheel in a multiversal race filled with adrenaline-fueled gameplay.",
                imageURL: URL(string: "https://raw.githubusercontent.com/ReSpringLover/imges/refs/heads/main/AETHERDRIFT.png") ,
                titleColor: UIColor(red: 28, green: 28, blue: 28),
                titleBackgroundColor: UIColor(red: 253, green: 185, blue: 1),
                buttonTextColor:UIColor(red: 28, green: 28, blue: 28),
                titleFontSize: 20,
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$6.51"
                )
            ),
            (
                title: "Duskmourn: house of horror".uppercased(),
                description: "Enter Duskmourn... if you dare. Set the scene for your opponent's greatest fears to come to life as shadows turn lethal.",
                imageURL: URL(string: "https://raw.githubusercontent.com/ReSpringLover/imges/refs/heads/main/Duskmourn_house_of_horror.png") ,
                titleColor: UIColor(red: 28, green: 28, blue: 28),
                titleBackgroundColor: UIColor(red: 157, green: 203, blue: 185),
                buttonTextColor:UIColor(red: 28, green: 28, blue: 28),
                titleFontSize: 14,
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$6.51"
                )
            ),
           
            (
                
                title: "bloomburrow".uppercased(),
                description: "Venture to a tiny idyllic land, and gather your friends in a woodland party, take to the battlefield and defend your folk!",
                imageURL: URL(string: "https://raw.githubusercontent.com/ReSpringLover/imges/refs/heads/main/bloomburrow.png") ,
                titleColor: UIColor(red: 255, green: 255, blue: 255),
                titleBackgroundColor: UIColor(red: 10, green: 107, blue: 61),
                buttonTextColor:UIColor(red: 28, green: 28, blue: 28),
                titleFontSize: 20,
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$6.51"
                )
            ),
        ]
        
        // Получаем 5 последних сетов-экспансий из Scryfall
        ScryfallServiceManager.shared.fetchLatestExpansions { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sets):
                    // Обновляем только BoosterBackData для каждой карточки
                    for (i, set) in sets.prefix(self?.boosterCardsData.count ?? 0).enumerated() {
                        // Формируем новые данные для обратной стороны
                        let newBack = BoosterBackData(
                            title: set.name,
                            details: "Код: \(set.code)\nТип: \(set.set_type)\nКарт: \(set.card_count)\nДата релиза: \(set.released_at)",
                            price: "$50" // Устанавливаем дефолтную цену
                        )
                        // Обновляем только backData, остальное не трогаем
                        self?.boosterCardsData[i].backData = newBack
                    }
                    self?.boosterCollectionView.reloadData()
                case .failure(let error):
                    print("Ошибка при получении сетов: \(error)")
                }
            }
        }
        pageControl.numberOfPages = boosterCardsData.count
        boosterCollectionView.reloadData()
    }
    
    // MARK: - Page Control Logic
    
    private func setupPageControl() {
        pageControl.numberOfPages = boosterCardsData.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let page = sender.currentPage
        currentPage = page
        scrollToPage(page, animated: true)
    }
    
    private func scrollToPage(_ page: Int, animated: Bool) {
        guard page >= 0 && page < boosterCardsData.count else { return }
        
        let indexPath = IndexPath(item: page, section: 0)
        boosterCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: animated
        )
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        boosterCardsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoosterCardCell.cellId, for: indexPath) as! BoosterCardCell
        
        let data = boosterCardsData[indexPath.item]
        let cardView = BoosterCardView(
            imageURL: data.imageURL,
            title: data.title,
            description: data.description,
            titleColor: data.titleColor,
            titleBackgroundColor: data.titleBackgroundColor,
            buttonTextColor: data.buttonTextColor,
            titleFontSize: data.titleFontSize,
            backData: data.backData
        )
        // Устанавливаем код сета для покупки
        cardView.configurePurchase(setCode: data.backData.title)
        // Обработка покупки
        cardView.onBuyTapped = { [weak self] purchaseInfo in
            guard let self = self else { return }
            let price = purchaseInfo.quantity * 50
            var balance = UserDataManager.shared.loadBalance()
            if balance.coins >= price {
                // Достаточно средств
                balance.coins -= price
                UserDataManager.shared.saveBalance(balance)
                self.balanceButton.updateBalance()
                // Сохраняем купленные бустеры
                var userBoosters = UserDataManager.shared.loadUnopenedBoosters()
                for _ in 0..<purchaseInfo.quantity {
                    let newBooster = UserBooster(
                        setCode: purchaseInfo.setCode,
                        type: purchaseInfo.type,
                        color: purchaseInfo.color
                    )
                    userBoosters.boosters.append(newBooster)
                }
                UserDataManager.shared.saveUnopenedBoosters(userBoosters)
                // Логируем информацию о покупке
                print("[Покупка] Куплено: сет=\(purchaseInfo.setCode), тип=\(purchaseInfo.type.rawValue), количество=\(purchaseInfo.quantity), новый баланс=\(balance.coins)")
                // Логируем все бустеры пользователя
                let allBoosters = UserDataManager.shared.loadUnopenedBoosters().boosters
                print("[Бустеры пользователя] Всего: \(allBoosters.count)")
                for booster in allBoosters {
                    print("  - setCode: \(booster.setCode), type: \(booster.type.rawValue), color: \(booster.colorHex ?? "nil"), id: \(booster.id)")
                }
                // Уведомляем другие экраны о покупке бустера
                NotificationCenter.default.post(name: .didPurchaseBooster, object: nil)
                // Показываем алерт об успешной покупке
                let alert = UIAlertController(title: "Покупка успешна", message: "Вы купили \(purchaseInfo.quantity) бустер(ов)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                // Недостаточно средств
                let alert = UIAlertController(title: "Недостаточно средств", message: "Пополните баланс для покупки.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        cell.configure(with: cardView)
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard let layout = boosterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cardWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let proposedOffsetX = targetContentOffset.pointee.x + boosterCollectionView.contentInset.left
        
        var pageIndex = round(proposedOffsetX / cardWidthIncludingSpacing)
        pageIndex = max(0, min(pageIndex, CGFloat(boosterCardsData.count - 1)))
        
        let newOffsetX = pageIndex * cardWidthIncludingSpacing - boosterCollectionView.contentInset.left
        targetContentOffset.pointee.x = newOffsetX
        
        currentPage = Int(pageIndex)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = boosterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cardWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = scrollView.contentOffset.x + boosterCollectionView.contentInset.left
        let page = Int(round(offsetX / cardWidthIncludingSpacing))
        
        if page >= 0 && page < boosterCardsData.count {
            pageControl.currentPage = page
            currentPage = page
        }
    }
}

extension Notification.Name {
    static let didPurchaseBooster = Notification.Name("didPurchaseBooster")
}
