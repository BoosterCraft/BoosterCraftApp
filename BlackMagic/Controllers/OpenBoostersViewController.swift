import UIKit


final class OpenBoostersViewController: UIViewController {

    private let balanceButton = BalanceButton()

    private var collectionView: UICollectionView!

    private let boosterData: [UserBooster] = [
        UserBooster(setCode: "TDM", type: .play, color: .systemTeal),
        UserBooster(setCode: "OTJ", type: .collector, color: .systemOrange),
        UserBooster(setCode: "WOE", type: .play, color: .purple),
        UserBooster(setCode: "NEO", type: .play, color: .systemPink),
        UserBooster(setCode: "ABC", type: .play, color: .systemGreen),
        UserBooster(setCode: "XYZ", type: .play, color: .systemRed),
        UserBooster(setCode: "TDM", type: .play, color: .systemTeal),
        UserBooster(setCode: "OTJ", type: .collector, color: .systemOrange),
        UserBooster(setCode: "WOE", type: .play, color: .purple),
        UserBooster(setCode: "NEO", type: .play, color: .systemPink),
        UserBooster(setCode: "ABC", type: .play, color: .systemGreen),
        UserBooster(setCode: "XYZ", type: .play, color: .systemRed),
        UserBooster(setCode: "TDM", type: .play, color: .systemTeal),
        UserBooster(setCode: "OTJ", type: .collector, color: .systemOrange),
        UserBooster(setCode: "WOE", type: .play, color: .purple),
        UserBooster(setCode: "NEO", type: .play, color: .systemPink),
        UserBooster(setCode: "ABC", type: .play, color: .systemGreen),
        UserBooster(setCode: "XYZ", type: .play, color: .systemRed)
    ]

    // Группируем бустеры по (setCode, type) и считаем количество
    private var groupedBoosters: [(booster: UserBooster, count: Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupCollectionView()
        groupBoostersForDisplay()
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

    private func groupBoostersForDisplay() {
        let boosters = boosterData
        var grouped: [BoosterKey: (booster: UserBooster, count: Int)] = [:]
        for booster in boosters {
            let key = BoosterKey(setCode: booster.setCode, type: booster.type)
            if let existing = grouped[key] {
                grouped[key] = (booster: existing.booster, count: existing.count + 1)
            } else {
                grouped[key] = (booster: booster, count: 1)
            }
        }
        groupedBoosters = Array(grouped.values)
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
        return groupedBoosters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OpenBoosterCardCell.identifier, for: indexPath) as! OpenBoosterCardCell
        let (booster, count) = groupedBoosters[indexPath.item]
        cell.cardView.configure(
            set: booster.setCode,
            type: booster.type.rawValue,
            count: count,
            color: UIColor.fromHexString(booster.colorHex ?? "") ?? .systemBlue
        )
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

