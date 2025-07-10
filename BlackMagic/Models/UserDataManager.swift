import Foundation

// Класс для управления пользовательскими данными (коллекция и баланс)
class UserDataManager {
    static let shared = UserDataManager()
    private init() {}
    
    // Ключи для UserDefaults
    private let collectionKey = "user_card_collection"
    private let balanceKey = "user_balance"
    private let boostersKey = "user_unopened_boosters"
    
    // Сохранить коллекцию пользователя
    func saveCollection(_ collection: UserCollection) {
        if let data = try? JSONEncoder().encode(collection) {
            UserDefaults.standard.set(data, forKey: collectionKey)
        }
    }
    
    // Загрузить коллекцию пользователя
    func loadCollection() -> UserCollection {
        if let data = UserDefaults.standard.data(forKey: collectionKey),
           let collection = try? JSONDecoder().decode(UserCollection.self, from: data) {
            return collection
        }
        // Если данных нет, возвращаем пустую коллекцию
        return UserCollection(cards: [])
    }
    
    // Сохранить баланс пользователя
    func saveBalance(_ balance: UserBalance) {
        if let data = try? JSONEncoder().encode(balance) {
            UserDefaults.standard.set(data, forKey: balanceKey)
        }
    }
    
    // Загрузить баланс пользователя
    func loadBalance() -> UserBalance {
        if let data = UserDefaults.standard.data(forKey: balanceKey),
           let balance = try? JSONDecoder().decode(UserBalance.self, from: data) {
            return balance
        }
        // Если данных нет, возвращаем баланс по умолчанию (например, 0)
        return UserBalance(coins: 0)
    }
    
    // Сохранить неоткрытые бустеры пользователя
    func saveUnopenedBoosters(_ boosters: UserBoosters) {
        if let data = try? JSONEncoder().encode(boosters) {
            UserDefaults.standard.set(data, forKey: boostersKey)
        }
    }
    
    // Загрузить неоткрытые бустеры пользователя
    func loadUnopenedBoosters() -> UserBoosters {
        if let data = UserDefaults.standard.data(forKey: boostersKey),
           let boosters = try? JSONDecoder().decode(UserBoosters.self, from: data) {
            return boosters
        }
        // Если данных нет, возвращаем пустой массив
        return UserBoosters(boosters: [])
    }

    // Добавить транзакцию и обновить баланс пользователя
    func addTransactionAndUpdateBalance(_ transaction: Transaction) {
        var balance = loadBalance()
        balance.coins += transaction.amount
        balance.transactions.append(transaction)
        saveBalance(balance)
    }

    // Получить историю транзакций пользователя
    func loadTransactions() -> [Transaction] {
        return loadBalance().transactions.sorted { $0.date > $1.date }
    }

    // Очистить всю историю транзакций пользователя
    func clearAllTransactions() {
        var balance = loadBalance()
        balance.transactions.removeAll()
        saveBalance(balance)
    }
} 
