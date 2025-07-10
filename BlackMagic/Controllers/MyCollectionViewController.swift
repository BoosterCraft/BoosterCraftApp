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

    // Группировка карт по сету: [set_name: [Card]]
    private var cardsBySet: [(setName: String, cards: [Card])] = []
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
        // Группируем карты по сету (set_name)
        let grouped = Dictionary(grouping: cardData) { $0.set_name ?? "Unknown Set" }
        // Сортируем по имени сета
        cardsBySet = grouped.keys.sorted().map { ($0, grouped[$0]!.sorted { $0.name < $1.name }) }
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
        
        // Динамический расчёт размеров для 3 карт в ряду
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 14
        let sideInset: CGFloat = 16

        let totalSpacing = spacing * (numberOfItemsPerRow - 1)
        let availableWidth = view.bounds.width - (sideInset * 2) - totalSpacing
        let cellWidth = floor(availableWidth / numberOfItemsPerRow)
        let cellHeight = cellWidth * 1.4 // Соотношение сторон карты
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)
        // Регистрируем header для секций
        collectionView.register(SetHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SetHeaderView")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 13)
        collectionView.pinLeft(to: view, sideInset)
        collectionView.pinRight(to: view, sideInset)
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
        // Уведомляем другие экраны об изменении баланса
        NotificationCenter.default.post(name: .didUpdateBalance, object: nil)
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Количество секций = количество сетов
        return cardsBySet.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Количество карт в секции
        return cardsBySet[section].cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = cardsBySet[indexPath.section].cards[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as! CardCell
        cell.configure(with: card, showBadge: true)
        cell.onSell = { [weak self] sellCount in
            self?.sellCard(withId: card.id, count: sellCount)
        }
        return cell
    }

    // Добавляем заголовок секции с названием сета
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SetHeaderView", for: indexPath) as! SetHeaderView
            header.titleLabel.text = cardsBySet[indexPath.section].setName
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Увеличиваем высоту заголовка секции для большего отступа
        return CGSize(width: collectionView.bounds.width, height: 54)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? CardCell)?.flip()
    }
}

// MARK: - Notification.Name Extension
extension Notification.Name {
    static let didOpenBooster = Notification.Name("didOpenBooster")
    static let didUpdateBalance = Notification.Name("didUpdateBalance")
}

// MARK: - Заголовок секции для коллекции
final class SetHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Используем кастомный шрифт PirataOne-Regular для заголовка секции
        titleLabel.font = UIFont(name: "PirataOne-Regular", size: 26) ?? .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        // Используем pin-методы вместо ручных constraints
        titleLabel.pinLeft(to: self, 8)
        titleLabel.pinRight(to: self, 8)
        titleLabel.pinTop(to: self)
        // Добавляем нижний отступ между заголовком и карточками
        titleLabel.pinBottom(to: self, 16)
        // Делаем фон полностью прозрачным
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
}

