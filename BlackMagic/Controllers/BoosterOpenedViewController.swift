import UIKit

final class BoosterOpenedViewController: UIViewController {

    // MARK: - Properties

    private let totalLabel = UILabel()
    private var collectionView: UICollectionView!

    // Массив реальных карт, полученных из Scryfall
    private var cards: [Card] = []
    
    // Множество выбранных карт (используем Set для быстрого поиска)
    private var selectedCards: Set<String> = []

    // Выбранный бустер, который передаётся при открытии экрана
    var booster: UserBooster!

    private let bottomBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        return view
    }()

    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private let sellAllButton = BoosterOpenedViewController.makeButton(title: "Sell all", bgColor: .systemGray)
    private let sellSelectedButton = BoosterOpenedViewController.makeButton(title: "Sell selected", bgColor: .systemGray)
    private let keepAllButton = BoosterOpenedViewController.makeButton(title: "Keep all", bgColor: .systemBlue)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        isModalInPresentation = true
        setupUI()
        // Загружаем карты для выбранного бустера
        guard let booster = booster else {
            print("[BoosterOpenedViewController] Ошибка: booster не передан!")
            return
        }
        print("[BoosterOpenedViewController] Загружаем карты для сета: \(booster.setCode)")
        ScryfallServiceManager.shared.fetchCards(forSet: booster.setCode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedCards):
                    // Выбираем случайные 12 уникальных карт из набора (или меньше, если карт меньше 12)
                    let count = min(12, fetchedCards.count)
                    let randomCards = Array(fetchedCards.shuffled().prefix(count))
                    self?.cards = randomCards
                    // Печатаем все image_url выбранных карт в консоль
                    for card in randomCards {
                        print("[BoosterOpenedViewController] image_url: \(card.image_url ?? "nil") for card: \(card.name)")
                    }
                    self?.collectionView.reloadData()
                    self?.updateStatsLabel()
                    self?.updateSellSelectedButton()
                case .failure(let error):
                    print("[BoosterOpenedViewController] Ошибка загрузки карт: \(error)")
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatsLabel()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Setup UI

    private func setupUI() {
        setupTotalLabel()
        setupCollectionView()
        setupBottomBar()
    }

    private func setupTotalLabel() {
        totalLabel.textColor = .white
        totalLabel.font = .boldSystemFont(ofSize: 16)
        totalLabel.textAlignment = .center

        view.addSubview(totalLabel)
        totalLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 8)
        totalLabel.pinLeft(to: view, 16)
        totalLabel.pinRight(to: view, 16)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 14
        let inset: CGFloat = 16

        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = view.bounds.width - (inset * 2) - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        let itemHeight = itemWidth * 1.4

        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: CardCell.identifier)

        view.addSubview(collectionView)
        collectionView.pinTop(to: totalLabel.bottomAnchor, 8)
        collectionView.pinLeft(to: view, inset)
        collectionView.pinRight(to: view, inset)
        collectionView.pinBottom(to: view, 98)
    }

    private func setupBottomBar() {
        view.addSubview(bottomBarBackgroundView)
        bottomBarBackgroundView.pinLeft(to: view)
        bottomBarBackgroundView.pinRight(to: view)
        bottomBarBackgroundView.pinBottom(to: view)
        bottomBarBackgroundView.setHeight(105)

        buttonsStackView.addArrangedSubview(sellAllButton)
        buttonsStackView.addArrangedSubview(sellSelectedButton)
        buttonsStackView.addArrangedSubview(keepAllButton)
        bottomBarBackgroundView.addSubview(buttonsStackView)

        buttonsStackView.pinLeft(to: bottomBarBackgroundView, 24)
        buttonsStackView.pinRight(to: bottomBarBackgroundView, 24)
        buttonsStackView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 13)
        buttonsStackView.setHeight(40)

        keepAllButton.addTarget(self, action: #selector(handleKeepAllTapped), for: .touchUpInside)
        sellSelectedButton.addTarget(self, action: #selector(handleSellSelectedTapped), for: .touchUpInside)
        sellAllButton.addTarget(self, action: #selector(handleSellAllTapped), for: .touchUpInside)
    }

    // MARK: - Card Selection Methods
    
    private func toggleCardSelection(at indexPath: IndexPath) {
        let card = cards[indexPath.item]
        let cardId = card.id
        
        if selectedCards.contains(cardId) {
            // Отменяем выбор карты
            selectedCards.remove(cardId)
            animateCardDeselection(at: indexPath)
        } else {
            // Выбираем карту
            selectedCards.insert(cardId)
            animateCardSelection(at: indexPath)
        }
        
        updateSellSelectedButton()
        updateStatsLabel()
    }
    
    private func animateCardSelection(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: {
            // Увеличиваем карту
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            
            // Добавляем синюю тень
            cell.layer.shadowColor = UIColor.systemBlue.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.shadowOpacity = 0.6
        })
    }
    
    private func animateCardDeselection(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: {
            // Возвращаем карту к нормальному размеру
            cell.transform = .identity
            
            // Убираем тень
            cell.layer.shadowColor = UIColor.clear.cgColor
            cell.layer.shadowOffset = .zero
            cell.layer.shadowRadius = 0
            cell.layer.shadowOpacity = 0
        })
    }
    
    private func updateSellSelectedButton() {
        let selectedCount = selectedCards.count
        sellSelectedButton.setTitle("Sell selected (\(selectedCount))", for: .normal)
        sellSelectedButton.isEnabled = selectedCount > 0
        sellSelectedButton.backgroundColor = selectedCount > 0 ? .systemRed : .systemGray
    }

    // MARK: - Utilities

    private func updateStatsLabel() {
        let totalCards = cards.count
        let selectedCount = selectedCards.count
        let totalPrice = (0..<cards.count).map { _ in Double.random(in: 0.01...3.5) }.reduce(0, +)
        let selectedPrice = (0..<selectedCount).map { _ in Double.random(in: 0.01...3.5) }.reduce(0, +)
        
        if selectedCount > 0 {
            totalLabel.text = "Total cards: \(totalCards) | Selected: \(selectedCount) | Selected price: $\(String(format: "%.2f", selectedPrice))"
        } else {
            totalLabel.text = "Total cards: \(totalCards)     Total price: $\(String(format: "%.2f", totalPrice))"
        }
    }

    @objc private func handleKeepAllTapped() {
        print("[BoosterOpenedViewController] Пользователь нажал 'Keep All'")
        
        // Сохраняем оставшиеся карты в коллекцию пользователя
        saveRemainingCardsToCollection()
        
        // Закрываем экран
        dismiss(animated: true)
    }
    
    private func saveRemainingCardsToCollection() {
        guard !cards.isEmpty else {
            print("[BoosterOpenedViewController] Нет карт для сохранения в коллекцию")
            return
        }
        
        print("[BoosterOpenedViewController] Начинаю сохранение \(cards.count) карт в коллекцию пользователя")
        
        // Загружаем текущую коллекцию пользователя
        let currentCollection = UserDataManager.shared.loadCollection()
        print("[BoosterOpenedViewController] Текущая коллекция содержит \(currentCollection.cards.count) карт")
        
        // Добавляем новые карты к существующей коллекции
        var updatedCollection = currentCollection
        updatedCollection.cards.append(contentsOf: cards)
        
        // Сохраняем обновленную коллекцию
        UserDataManager.shared.saveCollection(updatedCollection)
        
        print("[BoosterOpenedViewController] ✅ Успешно сохранено \(cards.count) карт в коллекцию")
        print("[BoosterOpenedViewController] 📊 Общее количество карт в коллекции: \(updatedCollection.cards.count)")
        
        // Выводим информацию о сохраненных картах
        for (index, card) in cards.enumerated() {
            print("[BoosterOpenedViewController] 💾 Сохранена карта \(index + 1): \(card.name) (ID: \(card.id))")
        }
        
        // Отправляем уведомление о том, что коллекция обновлена (бустер открыт)
        NotificationCenter.default.post(name: .didOpenBooster, object: nil)
    }
    
    @objc private func handleSellSelectedTapped() {
        guard !selectedCards.isEmpty else { return }
        
        print("[BoosterOpenedViewController] Пользователь продает \(selectedCards.count) выбранных карт")
        
        // Анимированно удаляем выбранные карты
        let selectedIndices = cards.enumerated().compactMap { index, card in
            selectedCards.contains(card.id) ? index : nil
        }.sorted(by: >) // Сортируем в обратном порядке для корректного удаления
        
        // Удаляем карты из массива
        for index in selectedIndices {
            let removedCard = cards.remove(at: index)
            print("[BoosterOpenedViewController] 🗑️ Продана карта: \(removedCard.name)")
        }
        
        // Очищаем выбранные карты
        selectedCards.removeAll()
        
        // Обновляем UI с анимацией
        UIView.animate(withDuration: 0.3) {
            self.collectionView.reloadData()
            self.updateStatsLabel()
            self.updateSellSelectedButton()
        }
        
        print("[BoosterOpenedViewController] Осталось карт: \(cards.count)")
    }
    
    @objc private func handleSellAllTapped() {
        print("[BoosterOpenedViewController] Пользователь продает все \(cards.count) карт")
        
        // Анимированно удаляем все карты
        cards.removeAll()
        selectedCards.removeAll()
        
        UIView.animate(withDuration: 0.3) {
            self.collectionView.reloadData()
            self.updateStatsLabel()
            self.updateSellSelectedButton()
        }
        
        print("[BoosterOpenedViewController] Все карты проданы, коллекция пуста")
    }

    private static func makeButton(title: String, bgColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = bgColor
        button.layer.cornerRadius = 8
        return button
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension BoosterOpenedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Показываем реальные карты, если они загружены, иначе 0
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardCell.identifier,
            for: indexPath
        ) as! CardCell

        // Берём реальную карту
        let card = cards[indexPath.item]
        let isSelected = selectedCards.contains(card.id)
        
        print("[BoosterOpenedViewController] Отображается карта: id=\(card.id), name=\(card.name), image_url=\(card.image_url ?? "nil"), selected=\(isSelected)")
        cell.configure(with: card, showBadge: false)
        
        // Применяем состояние выбора к ячейке
        if isSelected {
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            cell.layer.shadowColor = UIColor.systemBlue.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.shadowOpacity = 0.6
        } else {
            cell.transform = .identity
            cell.layer.shadowColor = UIColor.clear.cgColor
            cell.layer.shadowOffset = .zero
            cell.layer.shadowRadius = 0
            cell.layer.shadowOpacity = 0
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleCardSelection(at: indexPath)
    }
}
