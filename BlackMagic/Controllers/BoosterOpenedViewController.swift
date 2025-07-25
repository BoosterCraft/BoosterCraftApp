import UIKit

// Делегат для уведомления об открытии бустера
protocol BoosterOpenedViewControllerDelegate: AnyObject {
    func didOpenBooster()
}

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

    weak var delegate: BoosterOpenedViewControllerDelegate?

    // Флаг, указывающий на ошибку загрузки карт
    private var cardLoadFailed = false

    // Массив всех карт сета, полученных из Scryfall (для замены проблемных карт)
    private var allFetchedCards: [Card] = []

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
                    self?.allFetchedCards = fetchedCards
                    let count = min(12, fetchedCards.count)
                    let randomCards = Array(fetchedCards.shuffled().prefix(count))
                    self?.cards = randomCards
                    for card in randomCards {
                        print("[BoosterOpenedViewController] image_url: \(card.image_url ?? "nil") for card: \(card.name)")
                    }
                    self?.cardLoadFailed = false
                    self?.collectionView.reloadData()
                    self?.updateStatsLabel()
                    self?.updateSellSelectedButton()
                    self?.setActionButtonsEnabled(true)
                case .failure(let error):
                    print("[BoosterOpenedViewController] Ошибка загрузки карт: \(error)")
                    self?.cardLoadFailed = true
                    self?.cards = []
                    self?.allFetchedCards = []
                    self?.collectionView.reloadData()
                    self?.showCardLoadErrorUI()
                    self?.setActionButtonsEnabled(false)
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
        collectionView.pinTop(to: totalLabel.bottomAnchor, 20)
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
            
            cell.layer.shadowColor = UIColor.systemBlue.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 8)
            cell.layer.shadowRadius = 12
            cell.layer.shadowOpacity = 0.7
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
        // Сумма по реальным ценам всех карт
        let totalPrice = cards.compactMap { card in
            if let priceString = card.price_usd, let price = Double(priceString) {
                return price
            }
            return nil
        }.reduce(0.0, +)
        // Сумма по реальным ценам выбранных карт
        let selectedPrice = cards.filter { selectedCards.contains($0.id) }.compactMap { card in
            if let priceString = card.price_usd, let price = Double(priceString) {
                return price
            }
            return nil
        }.reduce(0.0, +)
        if selectedCount > 0 {
            totalLabel.text = "Selected: \(selectedCount) | Selected price: $\(String(format: "%.2f", selectedPrice))"
        } else {
            totalLabel.text = "Total cards: \(totalCards)     Total price: $\(String(format: "%.2f", totalPrice))"
        }
    }

    // Вспомогательный метод для отображения ошибки загрузки карт
    private func showCardLoadErrorUI() {
        // Показываем текст ошибки в totalLabel
        totalLabel.text = "Не удалось загрузить карты. Проверьте интернет-соединение."
    }

    // Вспомогательный метод для включения/отключения кнопок действий
    private func setActionButtonsEnabled(_ enabled: Bool) {
        keepAllButton.isEnabled = enabled
        sellAllButton.isEnabled = enabled
        sellSelectedButton.isEnabled = enabled
        keepAllButton.alpha = enabled ? 1.0 : 0.5
        sellAllButton.alpha = enabled ? 1.0 : 0.5
        sellSelectedButton.alpha = enabled ? 1.0 : 0.5
    }

    @objc private func handleKeepAllTapped() {
        // Если карты не загружены, ничего не делаем
        if cardLoadFailed || cards.isEmpty {
            print("[BoosterOpenedViewController] Нельзя сохранить карты: карты не загружены или их нет")
            return
        }
        print("[BoosterOpenedViewController] Пользователь нажал 'Keep All'")
        
        // Сохраняем оставшиеся карты в коллекцию пользователя
        saveRemainingCardsToCollection()
        
        // Отправляем уведомление для обновления коллекции карт
        NotificationCenter.default.post(name: .didOpenBooster, object: nil)
        
        // Удаляем один бустер этого типа из пользовательских данных
        removeOneOpenedBoosterFromUserData()
        
        // Уведомляем делегата об открытии бустера
        delegate?.didOpenBooster()
        
        // Закрываем экран
        dismiss(animated: true)
    }
    
    /// Удаляет один бустер этого типа из UserDefaults
    private func removeOneOpenedBoosterFromUserData() {
        // Загружаем текущие неоткрытые бустеры пользователя
        var userBoosters = UserDataManager.shared.loadUnopenedBoosters().boosters
        
        // Ищем индекс первого бустера с совпадающим setCode и type
        if let index = userBoosters.firstIndex(where: { $0.setCode == booster.setCode && $0.type == booster.type }) {
            // Удаляем найденный бустер
            userBoosters.remove(at: index)
            print("[BoosterOpenedViewController] Удалён один бустер типа \(booster.type) из сета \(booster.setCode)")
        } else {
            print("[BoosterOpenedViewController] Не найден бустер для удаления (setCode: \(booster.setCode), type: \(booster.type))")
        }
        // Сохраняем обновлённый список бустеров
        UserDataManager.shared.saveUnopenedBoosters(UserBoosters(boosters: userBoosters))
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
}
    
    @objc private func handleSellSelectedTapped() {
        // Если карты не загружены, ничего не делаем
        if cardLoadFailed || cards.isEmpty { return }
        guard !selectedCards.isEmpty else { return }
        print("[BoosterOpenedViewController] Пользователь продает \(selectedCards.count) выбранных карт")
        // Анимированно удаляем выбранные карты
        let selectedIndices = cards.enumerated().compactMap { index, card in
            selectedCards.contains(card.id) ? index : nil
        }.sorted(by: >) // Сортируем в обратном порядке для корректного удаления
        // Считаем сумму продажи выбранных карт
        var saleValue: Double = 0
        var soldNames: [String] = []
        for index in selectedIndices {
            let removedCard = cards.remove(at: index)
            if let priceString = removedCard.price_usd, let price = Double(priceString) {
                saleValue += price
            }
            soldNames.append(removedCard.name)
            print("[BoosterOpenedViewController] 🗑️ Продана карта: \(removedCard.name)")
        }
        // Очищаем выбранные карты
        selectedCards.removeAll()
        // Обновляем баланс пользователя и записываем транзакцию
        if saleValue > 0 {
            let tx = Transaction(type: .sellCard, amount: saleValue, date: Date(), details: "Продажа карт: \(soldNames.joined(separator: ", "))")
            UserDataManager.shared.addTransactionAndUpdateBalance(tx)
            NotificationCenter.default.post(name: .didUpdateBalance, object: nil)
        }
        // Обновляем UI с анимацией
        UIView.animate(withDuration: 0.3) {
            self.collectionView.reloadData()
            self.updateStatsLabel()
            self.updateSellSelectedButton()
        }
        print("[BoosterOpenedViewController] Осталось карт: \(cards.count)")
    }
    @objc private func handleSellAllTapped() {
        // Если карты не загружены, ничего не делаем
        if cardLoadFailed || cards.isEmpty { return }
        print("[BoosterOpenedViewController] Пользователь продает все \(cards.count) карт")
        // Считаем сумму продажи всех карт
        let saleValue: Double = cards.compactMap { card in
            if let priceString = card.price_usd, let price = Double(priceString) {
                return price
            }
            return nil
        }.reduce(0, +)
        let soldNames = cards.map { $0.name }
        // Анимированно удаляем все карты
        cards.removeAll()
        selectedCards.removeAll()
        // Обновляем баланс пользователя и записываем транзакцию
        if saleValue > 0 {
            let tx = Transaction(type: .sellCard, amount: saleValue, date: Date(), details: "Продажа всех карт: \(soldNames.joined(separator: ", "))")
            UserDataManager.shared.addTransactionAndUpdateBalance(tx)
            NotificationCenter.default.post(name: .didUpdateBalance, object: nil)
        }
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
        // Передаём callback для замены карты, если не удалось загрузить изображение
        cell.configure(with: card, showBadge: false, onImageLoadFailed: { [weak self] in
            self?.replaceCardWithNewRandom(at: indexPath.item)
        })
        // Применяем состояние выбора к ячейке
        if isSelected {
            cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            // Добавляем синюю тень (теперь больше и ярче)
            // Увеличено по просьбе: offset=8, radius=16, opacity=0.8
            cell.layer.shadowColor = UIColor.systemBlue.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 8)
            cell.layer.shadowRadius = 16
            cell.layer.shadowOpacity = 0.8
        } else {
            cell.transform = .identity
            cell.layer.shadowColor = UIColor.clear.cgColor
            cell.layer.shadowOffset = .zero
            cell.layer.shadowRadius = 0
            cell.layer.shadowOpacity = 0
        }
        return cell
    }

    // Заменяет карту на новую случайную из allFetchedCards, если не удалось загрузить изображение
    private func replaceCardWithNewRandom(at index: Int) {
        guard index < cards.count else { return }
        // Получаем id всех карт, которые уже в бустере
        let currentIds = Set(cards.map { $0.id })
        // Фильтруем только те карты, которых ещё нет в бустере
        let available = allFetchedCards.filter { !currentIds.contains($0.id) && $0.image_url != nil }
        guard let newCard = available.randomElement() else {
            print("[BoosterOpenedViewController] Нет доступных карт для замены!")
            return
        }
        print("[BoosterOpenedViewController] Заменяю карту на новую: \(newCard.name)")
        cards[index] = newCard
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleCardSelection(at: indexPath)
    }
}
