import Foundation

class ScryfallAPIService {
    static let shared = ScryfallAPIService()
    private let baseURL = "https://api.scryfall.com"
    private let userAgent = "BlackMagicApp/1.0"
    
    private init() {}
    
    func fetchCard(named name: String, completion: @escaping (Result<ScryfallCard, Error>) -> Void) {
        let urlString = "\(baseURL)/cards/named?exact=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let card = try JSONDecoder().decode(ScryfallCard.self, from: data)
                completion(.success(card))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCards(forSet setCode: String, completion: @escaping (Result<[ScryfallCard], Error>) -> Void) {
        let urlString = "\(baseURL)/cards/search?q=e:\(setCode)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ScryfallCardListResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCards(forSet setCode: String, numberRange: ClosedRange<Int>, completion: @escaping (Result<[ScryfallCard], Error>) -> Void) {
        let urlString = "\(baseURL)/cards/search?q=e:\(setCode)+number:\(numberRange.lowerBound)..\(numberRange.upperBound)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ScryfallCardListResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchAllSets(completion: @escaping (Result<[ScryfallSet], Error>) -> Void) {
        let urlString = "\(baseURL)/sets"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let result = try JSONDecoder().decode(ScryfallSetListResponse.self, from: data)
                completion(.success(result.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSet(byCode setCode: String, completion: @escaping (Result<ScryfallSet, Error>) -> Void) {
        let urlString = "\(baseURL)/sets/\(setCode)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let set = try JSONDecoder().decode(ScryfallSet.self, from: data)
                completion(.success(set))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private struct ScryfallCardListResponse: Codable {
        let data: [ScryfallCard]
    }
} 