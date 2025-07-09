import UIKit

final class BoosterOpenedViewController: UIViewController {

    // MARK: - Properties

    private let totalLabel = UILabel()
    private var collectionView: UICollectionView!

    // Массив реальных карт, полученных из Scryfall
    private var cards: [Card] = []

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
    }

    // MARK: - Utilities

    private func updateStatsLabel() {
        let totalCards = cards.count
        let totalPrice = (0..<cards.count).map { _ in Double.random(in: 0.01...3.5) }.reduce(0, +)
        totalLabel.text = "Total cards: \(totalCards)     Total price: $\(String(format: "%.2f", totalPrice))"
    }

    @objc private func handleKeepAllTapped() {
        dismiss(animated: true)
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
        print("[BoosterOpenedViewController] Отображается карта: id=\(card.id), name=\(card.name), image_url=\(card.image_url ?? "nil")")
        cell.configure(with: card, showBadge: false)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(booster.type)")
    }
}
