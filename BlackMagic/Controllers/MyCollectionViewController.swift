//
//  MyCollectionViewController.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//


import UIKit

final class MyCollectionViewController: UIViewController {

    private let balanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("$47.92", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()

    private var collectionView: UICollectionView!

    private var cardData: [Card] = [
        Card(id: 1, imageName: "Betor, Kin to All", price: 2.71, badgeCount: 1),
        Card(id: 2, imageName: "Magmatic Hellkite", price: 0.36, badgeCount: 2),
        Card(id: 3, imageName: "Roiling Dragonstorm", price: 0.12, badgeCount: 4),
        Card(id: 4, imageName: "Synchronized Charge", price: 0.15, badgeCount: 3),
        Card(id: 5, imageName: "Mardu Monument", price: 0.05, badgeCount: 1),
        Card(id: 6, imageName: "Purging Stormbrood", price: 0.07, badgeCount: 3),
        Card(id: 7, imageName: "Arashin Sunshield", price: 0.03, badgeCount: 1),
        Card(id: 8, imageName: "Focus the Mind", price: 0.06, badgeCount: 3),
        Card(id: 9, imageName: "Evolving Wilds", price: 0.10, badgeCount: 2)
    ]

    struct Card: Equatable {
        let id: Int
        let imageName: String
        let price: Double
        var badgeCount: Int
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        balanceButton.frame.size = balanceButton.intrinsicContentSize
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.setLargeTitleAccessoryView(with: balanceButton)
        title = "My collection"

        if let navBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular", size: 40) ?? .boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.white
            ]
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 111, height: 177)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 14

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        collectionView.pinLeft(to: view, 16)
        collectionView.pinRight(to: view, 16)
        collectionView.pinBottom(to: view)
    }

    private func sellCard(withId id: Int, count: Int) {
        guard let index = cardData.firstIndex(where: { $0.id == id }) else { return }

        var card = cardData[index]
        card.badgeCount = max(card.badgeCount - count, 0)

        if card.badgeCount == 0 {
            cardData.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        } else {
            cardData[index] = card
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension MyCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cardData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = cardData[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as! CardCell
        cell.configure(with: card)
        cell.onSell = { [weak self] sellCount in
            self?.sellCard(withId: card.id, count: sellCount)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? CardCell)?.flip()
    }
}
