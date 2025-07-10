// DailyRewardViewController.swift
// BlackMagic
// Страница ежедневной награды и истории транзакций

import UIKit

final class DailyRewardViewController: UIViewController {
    // Кнопка для получения награды
    private let rewardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Получить ежедневную награду (+500)", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    // Таблица для истории транзакций
    private let tableView = UITableView()
    // История транзакций
    private var transactions: [Transaction] = []
    // Для предотвращения повторного получения награды в течение дня
    private let lastRewardKey = "last_daily_reward_date"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Daily Reward"
        setupUI()
        loadTransactions()
        updateRewardButtonState()
        // Подписываемся на обновление баланса для автоматического обновления истории
        NotificationCenter.default.addObserver(self, selector: #selector(handleBalanceUpdate), name: .didUpdateBalance, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleBalanceUpdate() {
        loadTransactions()
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(rewardButton)
        view.addSubview(tableView)
        rewardButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Пин-код через pin-методы
        rewardButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 24)
        rewardButton.pinCenterX(to: view)
        tableView.pinTop(to: rewardButton.bottomAnchor, 24)
        tableView.pinLeft(to: view)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: view)
        rewardButton.addTarget(self, action: #selector(handleReward), for: .touchUpInside)
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(white: 1, alpha: 0.1)
    }

    // MARK: - Получение награды
    @objc private func handleReward() {
        // Проверяем, получал ли пользователь награду сегодня
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastRewardKey) as? Date
        guard lastDate == nil || Calendar.current.compare(today, to: lastDate!, toGranularity: .day) == .orderedDescending else {
            // Уже получал сегодня
            return
        }
        // Создаём транзакцию и обновляем баланс централизованно
        let transaction = Transaction(type: .dailyReward, amount: 500, date: Date(), details: "Ежедневная награда")
        UserDataManager.shared.addTransactionAndUpdateBalance(transaction)
        // Сохраняем дату получения награды
        UserDefaults.standard.set(today, forKey: lastRewardKey)
        // Обновляем UI
        updateRewardButtonState()
        // Обновляем таблицу
        loadTransactions()
        tableView.reloadData()
        // Отправляем уведомление для обновления баланса на других экранах
        NotificationCenter.default.post(name: .didUpdateBalance, object: nil)
    }

    private func updateRewardButtonState() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastRewardKey) as? Date
        if lastDate != nil && Calendar.current.compare(today, to: lastDate!, toGranularity: .day) == .orderedSame {
            rewardButton.isEnabled = false
            rewardButton.backgroundColor = .systemGray
            rewardButton.setTitle("Награда уже получена сегодня", for: .normal)
        } else {
            rewardButton.isEnabled = true
            rewardButton.backgroundColor = .systemGreen
            rewardButton.setTitle("Получить ежедневную награду (+500)", for: .normal)
        }
    }

    // MARK: - Работа с транзакциями
    private func loadTransactions() {
        transactions = UserDataManager.shared.loadTransactions()
    }
    private func saveTransaction(_ transaction: Transaction) {
        UserDataManager.shared.addTransactionAndUpdateBalance(transaction)
    }
}

// MARK: - UITableViewDataSource
extension DailyRewardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let tx = transactions[indexPath.row]
        cell.configure(with: tx)
        return cell
    }
}

// MARK: - Ячейка для транзакции
final class TransactionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray
        amountLabel.font = .boldSystemFont(ofSize: 16)
        amountLabel.textColor = .systemGreen
        contentView.addSubviews(titleLabel, dateLabel, amountLabel)
        titleLabel.pinTop(to: contentView, 8)
        titleLabel.pinLeft(to: contentView, 16)
        titleLabel.pinRight(to: amountLabel, 8)
        dateLabel.pinTop(to: titleLabel.bottomAnchor, 2)
        dateLabel.pinLeft(to: contentView, 16)
        dateLabel.pinBottom(to: contentView, 8)
        amountLabel.pinTop(to: contentView, 8)
        amountLabel.pinRight(to: contentView, 16)
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with tx: Transaction) {
        titleLabel.text = tx.details
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: tx.date)
        let sign = tx.amount > 0 ? "+" : ""
        // Показываем всегда два знака после запятой
        amountLabel.text = String(format: "%@%.2f", sign, tx.amount)
        amountLabel.textColor = tx.amount >= 0 ? .systemGreen : .systemRed
    }
} 