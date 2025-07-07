import UIKit


final class OpenBoostersViewController: UIViewController {

    private let balanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("$47.92", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()

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
        layout.itemSize = CGSize(width: 111, height: 155)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 14
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.clipsToBounds = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OpenBoosterCardCell.self, forCellWithReuseIdentifier: OpenBoosterCardCell.identifier)

        view.addSubview(collectionView)

        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        collectionView.pinLeft(to: view, 16)
        collectionView.pinRight(to: view, 16)
        collectionView.pinBottom(to: view)
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
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(boosterData[indexPath.item].type)")
    }
}

// MARK: - Data Model

