import Foundation

struct ScryfallCard: Codable, Identifiable {
    let id: String
    let name: String
    let setName: String
    let rarity: String
    let collectorNumber: String?
    let imageUris: ImageUris?
    let prices: Prices?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case setName = "set_name"
        case rarity
        case collectorNumber = "collector_number"
        case imageUris = "image_uris"
        case prices
    }
    
    struct ImageUris: Codable {
        let small: String?
        let normal: String?
    }
    
    struct Prices: Codable {
        let usd: String?
        let eur: String?
        let tix: String?
    }
} 