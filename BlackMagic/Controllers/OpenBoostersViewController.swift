import UIKit


final class OpenBoostersViewController: UIViewController {

    private let balanceButton = BalanceButton()

    private var collectionView: UICollectionView!

    // Массив всех неоткрытых бустеров пользователя (загружается из UserDefaults)
    private var userBoosters: [UserBooster] = []

    // Группируем бустеры по (setCode, type) и считаем количество
    private var groupedBoosters: [(booster: UserBooster, count: Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar(balanceButton, title: "Open boosters")
        setupCollectionView()
        reloadBoosters()
        // Подписываемся на уведомление о покупке бустера
        NotificationCenter.default.addObserver(self, selector: #selector(handleBoosterPurchase), name: .didPurchaseBooster, object: nil)
    }

    // MARK: Обновление баланса
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        balanceButton.updateBalance()
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

    // Загрузить бустеры пользователя и обновить UI
    private func reloadBoosters() {
        userBoosters = UserDataManager.shared.loadUnopenedBoosters().boosters
        groupBoostersForDisplay()
        collectionView.reloadData()
    }

    private func groupBoostersForDisplay() {
        let boosters = userBoosters
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

    private func presentBoosterOpenedViewController(for booster: UserBooster) {
        let openedVC = BoosterOpenedViewController()
        openedVC.booster = booster
        let nav = UINavigationController(rootViewController: openedVC)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }

    // Обработка уведомления о покупке бустера
    @objc private func handleBoosterPurchase() {
        reloadBoosters()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            let (booster, _) = self?.groupedBoosters[indexPath.item] ?? (nil, 0)
            if let booster = booster {
                self?.presentBoosterOpenedViewController(for: booster)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected booster: \(userBoosters[indexPath.item].type)")
    }
}
