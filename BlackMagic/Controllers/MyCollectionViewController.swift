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
    private var cardData: [Card] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar(balanceButton, title: "My collection")
        setupCollectionView()
        loadSavedCollection()
    }
    
    // MARK: - Загрузка сохраненной коллекции
    private func loadSavedCollection() {
        let userCollection = UserDataManager.shared.loadCollection()
        cardData = userCollection.cards
        collectionView.reloadData()
    }
    
//    // MARK: Обновление баланса
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        balanceButton.updateBalance()
        // Перезагружаем коллекцию при возвращении на экран
        loadSavedCollection()
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

    // MARK: - Продажа карт
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
        
        // Сохраняем обновленную коллекцию
        let updatedCollection = UserCollection(cards: cardData)
        UserDataManager.shared.saveCollection(updatedCollection)
        
        // Обновляем баланс (добавляем стоимость проданных карт)
        updateBalanceAfterSale(card: card, soldCount: count)
    }
    
    // MARK: - Обновление баланса после продажи
    private func updateBalanceAfterSale(card: Card, soldCount: Int) {
        guard let priceString = card.price_usd, let price = Double(priceString) else { return }
        
        let currentBalance = UserDataManager.shared.loadBalance()
        let saleValue = price * Double(soldCount)
        let newBalance = UserBalance(coins: currentBalance.coins + saleValue)
        
        UserDataManager.shared.saveBalance(newBalance)
        balanceButton.updateBalance()
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
        cell.configure(with: card, showBadge: true)
        cell.onSell = { [weak self] sellCount in
            self?.sellCard(withId: card.id, count: sellCount)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? CardCell)?.flip()
    }
}

