import Foundation

// Simple Card model for demonstration (expand as needed)
struct Card: Codable, CustomStringConvertible {
    let name: String
    let set: String?
    let rarity: String?
    let image_uris: [String: String]?
    
    var description: String {
        "Card(name: \(name), set: \(set ?? "-"), rarity: \(rarity ?? "-"))"
    }
}

class ScryfallServiceManager {
    static let shared = ScryfallServiceManager()
    private init() {}
    
    private let baseURL = "https://api.scryfall.com/cards/named?fuzzy="
    
    func fetchCard(named name: String, completion: @escaping (Result<Card, Error>) -> Void) {
        let nameQuery = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: baseURL + nameQuery) else {
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
} 