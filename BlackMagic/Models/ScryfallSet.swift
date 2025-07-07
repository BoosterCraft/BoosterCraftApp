import Foundation

struct ScryfallSet: Codable, Identifiable {
    let id: String
    let code: String
    let name: String
    let setType: String
    let cardCount: Int
    let iconSvgUri: String?
    let releasedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case setType = "set_type"
        case cardCount = "card_count"
        case iconSvgUri = "icon_svg_uri"
        case releasedAt = "released_at"
    }
}

struct ScryfallSetListResponse: Codable {
    let data: [ScryfallSet]
} 