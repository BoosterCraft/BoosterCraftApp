import UIKit

final class BoosterOpenedViewController: UIViewController {

    // MARK: - Properties

    private let totalLabel = UILabel()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 111, height: 155)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 14

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.clipsToBounds = false
        collectionView.register(OpenBoosterCardCell.self, forCellWithReuseIdentifier: OpenBoosterCardCell.identifier)
        return collectionView
    }()

    private let bottomBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1) // Dark consistent background color
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

    private var boosterData: [Booster] = [
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
        Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
        Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
        Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen),
        Booster(set: "XYZ", type: "Draft", count: 5, color: .systemRed),
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "WOE", type: "Draft", count: 2, color: .purple),
        Booster(set: "XYZ", type: "Draft", count: 3, color: .systemRed),
        Booster(set: "NEO", type: "SET", count: 1, color: .systemPink)
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        isModalInPresentation = true // ⛔ Prevent swipe-to-dismiss gesture
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatsLabel()
    }

    // MARK: - Setup UI

    private func setupUI() {
        // 🔠 Header label
        totalLabel.textColor = .white
        totalLabel.font = .boldSystemFont(ofSize: 16)
        totalLabel.textAlignment = .center

        view.addSubview(totalLabel)
        totalLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 8)
        totalLabel.pinLeft(to: view, 16)
        totalLabel.pinRight(to: view, 16)

        // 🔳 Collection View
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.pinTop(to: totalLabel.bottomAnchor, 8)
        collectionView.pinLeft(to: view, 16)
        collectionView.pinRight(to: view, 16)
        collectionView.pinBottom(to: view, 98) // Leaves space for buttons and bottom bar

        view.addSubview(bottomBarBackgroundView)
        bottomBarBackgroundView.pinLeft(to: view)
        bottomBarBackgroundView.pinRight(to: view)
        bottomBarBackgroundView.pinBottom(to: view)
        bottomBarBackgroundView.setHeight(105) // 50 (button) + 24 (bottom padding) + 32 visual

        // ➕ Stack View with spacing inside background
        buttonsStackView.addArrangedSubview(sellAllButton)
        buttonsStackView.addArrangedSubview(sellSelectedButton)
        buttonsStackView.addArrangedSubview(keepAllButton)

        bottomBarBackgroundView.addSubview(buttonsStackView)
        buttonsStackView.pinLeft(to: bottomBarBackgroundView, 24)   // more horizontal padding
        buttonsStackView.pinRight(to: bottomBarBackgroundView, 24)
        buttonsStackView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 13) // more bottom gap
        buttonsStackView.setHeight(40)

        // 🎯 Button Action
        keepAllButton.addTarget(self, action: #selector(handleKeepAllTapped), for: .touchUpInside)
    }

    // MARK: - Utility

    private func updateStatsLabel() {
        let totalCards = boosterData.count
        let totalPrice = (0..<boosterData.count).map { _ in Double.random(in: 0.01...3.5) }.reduce(0, +)
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
        return boosterData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OpenBoosterCardCell.identifier,
            for: indexPath
        ) as! OpenBoosterCardCell

        let booster = boosterData[indexPath.item]
        cell.cardView.configure(set: booster.set, type: booster.type, count: booster.count, color: booster.color)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(boosterData[indexPath.item].type)")
    }
}
