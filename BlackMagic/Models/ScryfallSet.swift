import Foundation

// Модель для представления сета Magic: The Gathering из Scryfall
struct ScryfallSet: Codable, CustomStringConvertible {
    // Уникальный код сета
    let code: String
    // Название сета
    let name: String
    // Тип сета (например, expansion)
    let set_type: String
    // Количество карт в сете
    let card_count: Int
    // Дата релиза
    let released_at: String
    // Ссылка на иконку сета (SVG)
    let icon_svg_uri: String?
    
    var description: String {
        "Сет: \(name) (код: \(code)), тип: \(set_type), карт: \(card_count), дата релиза: \(released_at)"
    }
}

// Модель для ответа Scryfall на список сетов
struct ScryfallSetsResponse: Codable {
    // Массив сетов
    let data: [ScryfallSet]
} 