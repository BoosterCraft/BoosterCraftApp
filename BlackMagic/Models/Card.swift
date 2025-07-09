import Foundation

// Полная модель карты Magic: The Gathering (по данным Scryfall, без связи с API)
struct Card: Codable, Equatable, CustomStringConvertible {
    // Уникальный идентификатор карты (например, Scryfall id)
    let id: String
    // Имя карты
    let name: String
    // Тип карты (например, "Creature — Dragon")
    let type_line: String?
    // Мана-стоимость
    let mana_cost: String?
    // Текст карты
    let oracle_text: String?
    // Редкость (например, "rare")
    let rarity: String?
    // Код сета
    let set: String?
    // Имя сета
    let set_name: String?
    // URL изображения (например, normal)
    let image_url: String?
    // Цена в долларах США (как в Scryfall API, например, "0.80")
    let price_usd: String?
    // Количество копий у пользователя
    var count: Int
    // Описание для отладки
    var description: String {
        "Card(name: \(name), set: \(set ?? "-"), rarity: \(rarity ?? "-"))"
    }
} 