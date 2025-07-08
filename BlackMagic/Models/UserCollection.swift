import Foundation

// Модель для хранения коллекции пользователя
struct UserCollection: Codable {
    // Массив идентификаторов карт (например, имена или id карт Scryfall)
    var cardIDs: [String]
}

// Модель для хранения баланса пользователя
struct UserBalance: Codable {
    // Баланс (например, количество монет)
    var coins: Int
} 