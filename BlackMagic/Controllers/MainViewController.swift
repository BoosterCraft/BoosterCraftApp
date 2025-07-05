import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Properties
    
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
        let cardHeight = view.frame.height * 0.52     // Slightly taller cards
        
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
        setupCardData()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(balanceButton)
        view.addSubview(boosterCollectionView)
        view.addSubview(pageControl)
        
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(to: view)
        
        balanceButton.pinTop(to: titleLabel.bottomAnchor, 16)
        balanceButton.pinCenterX(to: view)
        
        // Increased vertical spacing from balanceButton to collectionView
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
                title: "TARKIR: DRAGONSTORM",
                description: "Cinematic action, dynamic clan gameplay, and powerful new dragons.",
                imageName: "cardImage",
                titleColor: UIColor(red: 34, green: 45, blue: 87),
                titleBackgroundColor: UIColor(red: 219, green: 240, blue: 252),
                buttonTextColor: UIColor(red: 34, green: 45, blue: 87),
                BoosterBackData(
                    title: "TDM booster",
                    details: "• 5 Rare or higher\n• 3–5 Uncommon\n• 4–6 Common\n• 1 Full-art land",
                    price: "$26.28"
                )
            ),
            (
                title: "OUTLAWS OF THUNDER JUCTION",
                description: "Dark gothic horror, werewolves, and vampires — lead your clan to power.",
                imageName: "cardImage",

                titleColor: UIColor(red: 255, green: 255, blue: 255),
                titleBackgroundColor: UIColor(red: 236, green: 90, blue: 43),
                buttonTextColor: UIColor(red: 236, green: 90, blue: 43),
                BoosterBackData(
                    title: "Moonrise Pack",
                    details: "• 3 Rare\n• 4 Uncommon\n• 7 Common\n• 1 Token card",
                    price: "$19.80"
                )
            )
        ]
        
        pageControl.numberOfPages = boosterCardsData.count
        boosterCollectionView.reloadData()
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
            image: UIImage(named: data.imageName),
            title: data.title,
            description: data.description,
            titleColor: data.titleColor,
            titleBackgroundColor: data.titleBackgroundColor,
            buttonTextColor: data.buttonTextColor,
            backData: data.backData
        )
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
