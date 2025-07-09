import Foundation

// Модель для хранения коллекции пользователя
struct UserCollection: Codable {
    // Коллекция карт пользователя
    var cards: [Card]
}

// Модель для хранения баланса пользователя
struct UserBalance: Codable {
    // Баланс (например, количество монет)
    var coins: Double
} 
