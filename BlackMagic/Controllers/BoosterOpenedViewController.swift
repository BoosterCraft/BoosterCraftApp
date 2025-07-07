import UIKit

final class BoosterOpenedViewController: UIViewController {

    // MARK: - Properties

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

    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private let sellAllButton = BoosterOpenedViewController.makeButton(title: "Sell All", bgColor: .systemRed)
    private let sellSelectedButton = BoosterOpenedViewController.makeButton(title: "Sell Selected", bgColor: .systemBlue)
    private let keepAllButton = BoosterOpenedViewController.makeButton(title: "Keep All", bgColor: .systemGreen)

    private var boosterData: [Booster] = [
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
        Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
        Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
        Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen),
        Booster(set: "XYZ", type: "Draft", count: 5, color: .systemRed),
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupUI()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "Booster Opened"
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular", size: 40) ?? .boldSystemFont(ofSize: 30),
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

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(buttonsStackView)

        // Setup collection view layout
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        collectionView.pinLeft(to: view, 16)
        collectionView.pinRight(to: view, 16)
        collectionView.pinBottom(to: buttonsStackView.topAnchor, 16)

        // Setup buttons
        buttonsStackView.addArrangedSubview(sellAllButton)
        buttonsStackView.addArrangedSubview(sellSelectedButton)
        buttonsStackView.addArrangedSubview(keepAllButton)

        buttonsStackView.pinLeft(to: view, 16)
        buttonsStackView.pinRight(to: view, 16)
        buttonsStackView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 16)
        buttonsStackView.setHeight(44)

        keepAllButton.addTarget(self, action: #selector(handleKeepAllButtonTap), for: .touchUpInside)
    }

    @objc private func handleKeepAllButtonTap() {
        collectionView.setContentOffset(.zero, animated: true)
    }

    private static func makeButton(title: String, bgColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = bgColor
        button.layer.cornerRadius = 8
        return button
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension BoosterOpenedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boosterData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenBoosterCardCell.identifier, for: indexPath) as! OpenBoosterCardCell
        let booster = boosterData[indexPath.item]
        cell.cardView.configure(set: booster.set, type: booster.type, count: booster.count, color: booster.color)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(boosterData[indexPath.item].type)")
    }
}
