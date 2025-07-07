//
//  OpenBoostersViewController 2.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//


import UIKit


final class MyCollectionViewController: UIViewController {

    // MARK: - Properties

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

    private var collectionView: UICollectionView!
    
    private let cardData: [Card] = [
        Card(imageName: "Betor, Kin to All", price: 2.71, badgeCount: 1),
        Card(imageName: "Magmatic Hellkite", price: 0.36, badgeCount: nil),
        Card(imageName: "Roiling Dragonstorm", price: 0.12, badgeCount: nil),
        Card(imageName: "Synchronized Charge", price: 0.15, badgeCount: nil),
        Card(imageName: "Mardu Monument", price: 0.05, badgeCount: nil),
        Card(imageName: "Pursing Stormbrood", price: 0.07, badgeCount: nil),
        Card(imageName: "Arashin Sunshield", price: 0.03, badgeCount: nil),
        Card(imageName: "Focus the Mind", price: 0.06, badgeCount: nil),
        Card(imageName: "Evolving Wilds", price: 0.10, badgeCount: nil),
    ]
    
    // Ключ для сохранения статуса онбординга
    private let onboardingKey = "hasCompletedOnboarding"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupCollectionView()
    }
    
    

    // MARK: - Setup

    private func setupNavigationBar() {
        let accessoryView = balanceButton
        accessoryView.frame.size = accessoryView.intrinsicContentSize

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.setLargeTitleAccessoryView(with: accessoryView)
        
        title = "My collection"

        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular", size: 40) ?? UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white
            ]
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.white
            ]

            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)

        view.addSubview(collectionView)
        
        collectionView.pin(to: view)
    }
}

// MARK: - Data Models
private extension MyCollectionViewController {
    struct Card {
        let imageName: String
        let price: Double
        let badgeCount: Int?
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MyCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as? CardCell else {
            fatalError("Failed to dequeue CardCell.")
        }
        let card = cardData[indexPath.item]
        cell.configure(with: card)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let numberOfColumns: CGFloat = 3
        
        let totalHorizontalPadding = padding * (numberOfColumns + 1)
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let itemWidth = availableWidth / numberOfColumns
        
        let itemHeight = (itemWidth * 1.4) + 8 + 20
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding: CGFloat = 16
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - CardCell
private final class CardCell: UICollectionViewCell {
    static let identifier = "CardCell"
    
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .darkGray
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = false
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubviews(cardImageView, priceLabel, badgeView)
        badgeView.addSubview(badgeLabel)
        
        priceLabel.pinHorizontal(to: contentView)
        priceLabel.pinBottom(to: contentView)
        priceLabel.setHeight(20)

        cardImageView.pinTop(to: contentView)
        cardImageView.pinHorizontal(to: contentView)
        cardImageView.pinBottom(to: priceLabel.topAnchor, 8)
        
        badgeView.pinTop(to: cardImageView.topAnchor, -8)
        badgeView.pinRight(to: cardImageView.trailingAnchor, -8)
        badgeView.setHeight(24)
        badgeView.setWidth(24)
        
        badgeLabel.pinCenter(to: badgeView)
    }
    
    func configure(with card: MyCollectionViewController.Card) {
        cardImageView.image = UIImage(named: card.imageName)
        priceLabel.text = String(format: "$%.2f", card.price)
        
        if let count = card.badgeCount {
            badgeView.isHidden = false
            badgeLabel.text = "\(count)"
        } else {
            badgeView.isHidden = true
        }
    }
}
