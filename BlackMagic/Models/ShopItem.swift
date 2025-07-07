import Foundation

enum ShopItemType {
    case booster
    case set
}

struct ShopItem {
    let id: String
    let name: String
    let type: ShopItemType
    let price: Int
    let booster: Booster?
    // Add set info if needed
} 