import UIKit


final class OpenBoostersViewController: UIViewController {

    private let balanceButton = BalanceButton()

    private var collectionView: UICollectionView!

    private let boosterData: [Booster] = [
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
        Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
        Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
        Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen),
        Booster(set: "XYZ", type: "Draft", count: 5, color: .systemRed),
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
        Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
        Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
        Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen),
        Booster(set: "XYZ", type: "Draft", count: 5, color: .systemRed),
        Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
        Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
        Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
        Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
        Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen),
        Booster(set: "XYZ", type: "Draft", count: 5, color: .systemRed),

    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        let accessoryView = balanceButton
        accessoryView.frame.size = CGSize(width: 50, height: 34)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.setLargeTitleAccessoryView(with: accessoryView)
        title = "Open boosters"

        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular", size: 40)!,
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

        view.backgroundColor = .black
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 14
        let sideInset: CGFloat = 16

        let totalSpacing = spacing * (numberOfItemsPerRow - 1)
        let availableWidth = view.bounds.width - (sideInset * 2) - totalSpacing
        let cellWidth = floor(availableWidth / numberOfItemsPerRow)
        let cellHeight = cellWidth * 1.4 // Adjust ratio for visual appeal
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OpenBoosterCardCell.self, forCellWithReuseIdentifier: OpenBoosterCardCell.identifier)

        view.addSubview(collectionView)

        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        collectionView.pinLeft(to: view, sideInset)
        collectionView.pinRight(to: view, sideInset)
        collectionView.pinBottom(to: view)
    }
    private func presentBoosterOpenedViewController() {
        let openedVC = BoosterOpenedViewController()
        let nav = UINavigationController(rootViewController: openedVC)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension OpenBoostersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boosterData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenBoosterCardCell.identifier, for: indexPath) as! OpenBoosterCardCell
        let booster = boosterData[indexPath.item]
        cell.cardView.configure(set: booster.set, type: booster.type, count: booster.count, color: booster.color)
        cell.onOpenTapped = { [weak self] in
                self?.presentBoosterOpenedViewController()
            }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(boosterData[indexPath.item].type)")
    }
}

// MARK: - Data Model

