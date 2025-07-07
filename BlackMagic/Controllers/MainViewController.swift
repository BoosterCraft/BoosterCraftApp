import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    private var boosterData: [BoosterData] = []
    private var boosterCardsData: [(title: String, description: String, imageName: String, titleColor: UIColor, titleBackgroundColor: UIColor, buttonTextColor: UIColor, backData: BoosterBackData)] = []
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Black magic"
        label.font = UIFont(name: "PirataOne-Regular", size: 34)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let balanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("$47.92", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()
    
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
        setupLayout()
        loadBoosterData()
        setupPageControl()
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
    
    private func loadBoosterData() {
        // Use predefined boosters for now
        boosterData = BoosterData.predefinedBoosters
        
        // Convert to the format expected by the collection view
        boosterCardsData = boosterData.map { booster in
            (
                title: booster.setName,
                description: booster.description,
                imageName: booster.imageName,
                titleColor: booster.titleColor,
                titleBackgroundColor: booster.titleBackgroundColor,
                buttonTextColor: booster.buttonTextColor,
                BoosterBackData(
                    title: "\(booster.setCode.uppercased()) Booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land\n• Cards \(booster.cardRange.lowerBound)-\(booster.cardRange.upperBound)",
                    price: booster.price
                )
            )
        }
        
        pageControl.numberOfPages = boosterCardsData.count
        boosterCollectionView.reloadData()
        
        // Optionally fetch additional data from Scryfall API
        fetchSetDataFromAPI()
    }
    
    private func fetchSetDataFromAPI() {
        // This method can be used to fetch additional set information from Scryfall
        print("Could fetch additional set data from Scryfall API for \(boosterData.count) sets")
        
        // Example: Fetch cards for the first booster (TDM)
        if let firstBooster = boosterData.first {
            ScryfallAPIService.shared.fetchCards(forSet: firstBooster.setCode, numberRange: firstBooster.cardRange) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let cards):
                        print("✅ Successfully fetched \(cards.count) cards for \(firstBooster.setCode.uppercased()) set")
                        // Here you could store the cards or use them for booster opening
                        self.handleFetchedCards(cards, forSet: firstBooster.setCode)
                    case .failure(let error):
                        print("❌ Error fetching cards for \(firstBooster.setCode): \(error)")
                    }
                }
            }
        }
        
        // Fetch set icons for all boosters
        fetchSetIconsForBoosters()
    }
    
    private func fetchSetIconsForBoosters() {
        for (index, booster) in boosterData.enumerated() {
            ScryfallAPIService.shared.fetchSet(byCode: booster.setCode) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let set):
                        print("✅ Fetched set icon for \(booster.setCode): \(set.iconSvgUri ?? "No icon")")
                        // You could update the booster data here if needed
                        // For now, we're using the predefined URLs
                    case .failure(let error):
                        print("❌ Error fetching set info for \(booster.setCode): \(error)")
                    }
                }
            }
        }
    }
    
    private func handleFetchedCards(_ cards: [ScryfallCard], forSet setCode: String) {
        // This method handles the fetched cards
        // You could store them in a cache, use them for booster opening, etc.
        print("📦 Received \(cards.count) cards for set \(setCode)")
        
        // Example: Print first few cards
        let firstCards = Array(cards.prefix(3))
        for card in firstCards {
            print("  - \(card.name) (\(card.rarity))")
        }
    }
    
    // Method to fetch cards for a specific booster (can be called when user wants to open a booster)
    func fetchCardsForBooster(_ booster: BoosterData, completion: @escaping ([ScryfallCard]) -> Void) {
        ScryfallAPIService.shared.fetchCards(forSet: booster.setCode, numberRange: booster.cardRange) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cards):
                    print("✅ Fetched \(cards.count) cards for \(booster.setCode.uppercased()) booster")
                    completion(cards)
                case .failure(let error):
                    print("❌ Error fetching cards for \(booster.setCode): \(error)")
                    completion([])
                }
            }
        }
    }
    
    // Method to open a booster and get random cards
    func openBooster(_ booster: BoosterData, completion: @escaping ([ScryfallCard], Double) -> Void) {
        fetchCardsForBooster(booster) { cards in
            if !cards.isEmpty {
                let openedCards = BoosterOpeningService.shared.openBooster(from: cards)
                let totalValue = BoosterOpeningService.shared.calculateBoosterValue(openedCards)
                
                print("🎉 Opened \(booster.setCode.uppercased()) booster!")
                print("📦 Got \(openedCards.count) cards with total value: $\(String(format: "%.2f", totalValue))")
                
                for card in openedCards {
                    let value = BoosterOpeningService.shared.getCardValue(card)
                    print("  - \(card.name) (\(card.rarity)) - $\(String(format: "%.2f", value))")
                }
                
                completion(openedCards, totalValue)
            } else {
                completion([], 0.0)
            }
        }
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
        guard page >= 0 && page < boosterData.count else { return }
        
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
        boosterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoosterCardCell.cellId, for: indexPath) as! BoosterCardCell
        
        let booster = boosterData[indexPath.item]
        let backData = BoosterBackData(
            title: "\(booster.setCode.uppercased()) Booster",
            details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land\n• Cards \(booster.cardRange.lowerBound)-\(booster.cardRange.upperBound)",
            price: booster.price
        )
        
        let cardView = BoosterCardView(boosterData: booster, backData: backData)
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
        pageIndex = max(0, min(pageIndex, CGFloat(boosterData.count - 1)))
        
        let newOffsetX = pageIndex * cardWidthIncludingSpacing - boosterCollectionView.contentInset.left
        targetContentOffset.pointee.x = newOffsetX
        
        currentPage = Int(pageIndex)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = boosterCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let cardWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = scrollView.contentOffset.x + boosterCollectionView.contentInset.left
        let page = Int(round(offsetX / cardWidthIncludingSpacing))
        
        if page >= 0 && page < boosterData.count {
            pageControl.currentPage = page
            currentPage = page
        }
    }
}
