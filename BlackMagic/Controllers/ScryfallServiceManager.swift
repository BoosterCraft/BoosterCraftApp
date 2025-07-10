import Foundation
import UIKit

// Импортируем модель сета
// (предполагается, что файл ScryfallSet.swift находится в папке Models)
// Если потребуется, используйте @testable import BlackMagic для тестов

// import Card из Models/Card.swift

class ScryfallServiceManager {
    // Синглтон для удобного доступа
    static let shared = ScryfallServiceManager()
    private init() {}
    
    // Базовый URL для поиска карты по имени
    private let cardBaseURL = "https://api.scryfall.com/cards/named?fuzzy="
    // URL для получения всех сетов
    private let setsURL = "https://api.scryfall.com/sets"
    
    // Получить карту по имени
    // name — имя карты
    // completion — замыкание с результатом (успех или ошибка)
    func fetchCard(named name: String, completion: @escaping (Result<Card, Error>) -> Void) {
        let nameQuery = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: cardBaseURL + nameQuery) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let card = try JSONDecoder().decode(Card.self, from: data)
                completion(.success(card))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // Получить 5 последних сетов, соответствующих условиям:
    // set_type = "expansion", card_count >= 150, released_at < текущая дата
    func fetchLatestExpansions(completion: @escaping (Result<[ScryfallSet], Error>) -> Void) {
        guard let url = URL(string: setsURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                // Декодируем ответ
                let setsResponse = try JSONDecoder().decode(ScryfallSetsResponse.self, from: data)
                let allSets = setsResponse.data
                // Получаем текущую дату
                let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                // Фильтруем по условиям
                let filtered = allSets.filter { set in
                    print((dateFormatter.date(from: set.released_at) ?? Date.distantPast))
                    return set.set_type == "expansion" &&
                    set.card_count >= 150 &&
                    (dateFormatter.date(from: set.released_at) ?? Date.distantPast) < now
                }
                // Сортируем по дате релиза (от новых к старым)
                let sorted = filtered.sorted {
                    (dateFormatter.date(from: $0.released_at) ?? Date.distantPast) >
                    (dateFormatter.date(from: $1.released_at) ?? Date.distantPast)
                }
                // Берём 5 последних
                let latestFive = Array(sorted.prefix(5))
                completion(.success(latestFive))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Логирование
    private func log(_ message: String) {
        print("[ScryfallServiceManager] " + message)
    }

    // MARK: - Получение карт с логированием
    func fetchCards(forSet setCode: String, completion: @escaping (Result<[Card], Error>) -> Void) {
        var allCards: [Card] = []
        let baseURL = "https://api.scryfall.com/cards/search?q=e:\(setCode)"
        log("Начинаю загрузку карт для сета: \(setCode), URL: \(baseURL)")
        
        func fetchPage(url: String) {
            guard let url = URL(string: url) else {
                self.log("Ошибка: некорректный URL: \(url)")
                completion(.failure(NSError(domain: "bad_url", code: 0)))
                return
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    self.log("Ошибка загрузки: \(error)")
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    self.log("Нет данных в ответе")
                    completion(.failure(NSError(domain: "no_data", code: 0)))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ScryfallCardsResponse.self, from: data)
                    // Логируем JSON-объект каждой карты
                    if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let cards = jsonArray["data"] as? [[String: Any]] {
                        for cardJSON in cards {
                            if let cardData = try? JSONSerialization.data(withJSONObject: cardJSON),
                               let cardString = String(data: cardData, encoding: .utf8) {
                                self.log("JSON карты: \(cardString)")
                            }
                        }
                    }
                    let pageCards = response.data.map { $0.toCard() }
                    allCards.append(contentsOf: pageCards)
                    if let next = response.next_page {
                        fetchPage(url: next)
                    } else {
                        self.log("Загружено всего карт: \(allCards.count)")
                        completion(.success(allCards))
                    }
                } catch {
                    self.log("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            }.resume()
        }
        fetchPage(url: baseURL)
    }

    // MARK: - Асинхронная загрузка изображения карты с логированием
    func loadCardImage(from urlString: String?, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.log("Ошибка: некорректный URL изображения: \(urlString ?? "nil")")
            completion(nil as UIImage?)
            return
        }
        self.log("Начинаю загрузку изображения: \(url)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                self.log("Ошибка загрузки изображения: \(error)")
                completion(nil as UIImage?)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                self.log("Ошибка: не удалось создать изображение из данных")
                completion(nil as UIImage?)
                return
            }
            self.log("Изображение успешно загружено: \(url)")
            completion(image)
        }.resume()
    }
} 

// MARK: - Вспомогательные структуры для декодирования Scryfall
private struct ScryfallCardsResponse: Codable {
    let data: [ScryfallCard]
    let next_page: String?
}

private struct ScryfallCard: Codable {
    let id: String
    let name: String
    let type_line: String?
    let mana_cost: String?
    let oracle_text: String?
    let rarity: String?
    let set: String?
    let set_name: String?
    let image_uris: [String: String]?
    // Важно: значения в prices могут быть null (например, "usd_etched": null), поэтому используем String? как значение
    let prices: [String: String?]?
    
    func toCard() -> Card {
        Card(
            id: id,
            name: name,
            type_line: type_line,
            mana_cost: mana_cost,
            oracle_text: oracle_text,
            rarity: rarity,
            set: set,
            set_name: set_name,
            image_url: image_uris?["large"],
            price_usd: prices?["usd"] ?? nil,
            count: 1
        )
    }
} 
