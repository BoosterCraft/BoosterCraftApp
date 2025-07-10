// Transaction.swift
// BlackMagic
// Модель и хранилище для истории транзакций пользователя

import Foundation

// Типы транзакций
enum TransactionType: String, Codable {
    case buyBooster
    case sellCard
    case dailyReward
}

// Модель транзакции
struct Transaction: Codable {
    let type: TransactionType
    let amount: Double
    let date: Date
    let details: String // Описание (например, "Продажа карты: Black Lotus")
}

// Хранилище транзакций (UserDefaults)
class TransactionStorage {
    static let shared = TransactionStorage()
    private let key = "user_transactions"
    private init() {}

    func load() -> [Transaction] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let txs = try? JSONDecoder().decode([Transaction].self, from: data) else {
            return []
        }
        return txs.sorted { $0.date > $1.date }
    }

    func add(_ tx: Transaction) {
        var txs = load()
        txs.append(tx)
        if let data = try? JSONEncoder().encode(txs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
} 