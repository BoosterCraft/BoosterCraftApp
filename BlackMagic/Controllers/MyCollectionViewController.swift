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
    private var expandedCardSnapshot: UIView? // Снапшот увеличенной карточки
    private var overlayView: UIView? // Затемнение фона
    private var originalCellFrame: CGRect? // Оригинальная рамка ячейки
    private var expandedIndexPath: IndexPath? // Индекс выбранной ячейки

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar(balanceButton, title: "My collection")
        setupCollectionView()
        loadSavedCollection()
        // Подписываемся на уведомление об открытии бустера
        NotificationCenter.default.addObserver(self, selector: #selector(handleBoosterOpened), name: .didOpenBooster, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Обработка уведомления об открытии бустера
    @objc private func handleBoosterOpened() {
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
        // Удаляем автоматическую перезагрузку коллекции
        // loadSavedCollection()
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
        // Добавляем жест долгого нажатия
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
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

    // MARK: - Обработка долгого нажатия на карточку
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location),
              let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        switch gesture.state {
        case .began:
            // Если уже есть увеличенная карточка, ничего не делаем
            guard expandedCardSnapshot == nil else { return }
            // Создаем снапшот ячейки
            guard let snapshot = cell.snapshotView(hidePriceAndBadge: true) else { return }
            let cellFrame = cell.convert(cell.bounds, to: view)
            snapshot.frame = cellFrame
            view.addSubview(snapshot)
            cell.isHidden = true

            // Создаем затемнение фона
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            overlay.alpha = 0
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
            overlay.addGestureRecognizer(tap)
            view.insertSubview(overlay, belowSubview: snapshot)

            // Анимируем увеличение карточки и появление затемнения
            UIView.animate(withDuration: 0.3, animations: {
                overlay.alpha = 1
                let center = self.view.center
                let scale: CGFloat = 3.1 
                snapshot.center = center
                snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
            })

            expandedCardSnapshot = snapshot
            overlayView = overlay
            originalCellFrame = cellFrame
            expandedIndexPath = indexPath
        default:
            break
        }
    }

    // MARK: - Обработка тапа по затемнению для возврата карточки
    @objc private func handleOverlayTap() {
        guard let snapshot = expandedCardSnapshot,
              let overlay = overlayView,
              let indexPath = expandedIndexPath,
              let cellFrame = originalCellFrame,
              let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }

        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
            snapshot.frame = cellFrame
            snapshot.transform = .identity
        }, completion: { _ in
            cell.isHidden = false
            snapshot.removeFromSuperview()
            overlay.removeFromSuperview()
            self.expandedCardSnapshot = nil
            self.overlayView = nil
            self.originalCellFrame = nil
            self.expandedIndexPath = nil
        })
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

// MARK: - Notification.Name Extension
extension Notification.Name {
    static let didOpenBooster = Notification.Name("didOpenBooster")
}

