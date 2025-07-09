//
//  MyCollectionViewController.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//


import UIKit
import Foundation

final class MyCollectionViewController: UIViewController {

    private let balanceButton = BalanceButton()

    private var collectionView: UICollectionView!
    private var cardData: [Card] = [
        Card(id: "1", name: "Betor, Kin to All", type_line: "Creature", mana_cost: "{2}{R}", oracle_text: "Flying, trample", rarity: "rare", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "2.71", count: 1),
        Card(id: "2", name: "Magmatic Hellkite", type_line: "Creature", mana_cost: "{4}{R}{R}", oracle_text: "Flying, haste", rarity: "rare", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.36", count: 2),
        Card(id: "3", name: "Roiling Dragonstorm", type_line: "Sorcery", mana_cost: "{5}{R}{R}", oracle_text: "Storm", rarity: "mythic", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.12", count: 4),
        Card(id: "4", name: "Synchronized Charge", type_line: "Instant", mana_cost: "{2}{W}", oracle_text: "Creatures you control get +2/+1", rarity: "uncommon", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.15", count: 3),
        Card(id: "5", name: "Mardu Monument", type_line: "Artifact", mana_cost: "{3}", oracle_text: "Add {R}, {W}, or {B}", rarity: "rare", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.05", count: 1),
        Card(id: "6", name: "Purging Stormbrood", type_line: "Creature", mana_cost: "{3}{B}", oracle_text: "Deathtouch", rarity: "rare", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.07", count: 3),
        Card(id: "7", name: "Arashin Sunshield", type_line: "Creature", mana_cost: "{1}{W}", oracle_text: "Vigilance", rarity: "common", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.03", count: 1),
        Card(id: "8", name: "Focus the Mind", type_line: "Sorcery", mana_cost: "{U}", oracle_text: "Draw a card", rarity: "common", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.06", count: 3),
        Card(id: "9", name: "Evolving Wilds", type_line: "Land", mana_cost: nil, oracle_text: "Search your library for a basic land card", rarity: "common", set: "TDM", set_name: "Test Set", image_url: nil, price_usd: "0.10", count: 2)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar(balanceButton, title: "My collection")
        setupCollectionView()
    }
    
//    // MARK: Обновление баланса
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        balanceButton.updateBalance()
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

    private func sellCard(withId id: String, count: Int) {
        guard let index = cardData.firstIndex(where: { $0.id == id }) else { return }

        var card = cardData[index]
        card.count = max(card.count - count, 0)

        if card.count == 0 {
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

