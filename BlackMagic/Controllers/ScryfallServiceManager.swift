import Foundation

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
                let dateFormatter = ISO8601DateFormatter()
                // Фильтруем по условиям
                let filtered = allSets.filter { set in
                    set.set_type == "expansion" &&
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
} 
