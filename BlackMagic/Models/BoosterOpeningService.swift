import Foundation

class BoosterOpeningService {
    static let shared = BoosterOpeningService()
    
    private init() {}
    
    // Standard booster pack composition
    private let boosterComposition: [String: Double] = [
        "common": 10,
        "uncommon": 3,
        "rare": 1,
        "mythic": 0.125 // 1 in 8 packs
    ]
    
    func openBooster(from cards: [ScryfallCard]) -> [ScryfallCard] {
        var selectedCards: [ScryfallCard] = []
        
        // Separate cards by rarity
        let cardsByRarity = Dictionary(grouping: cards) { $0.rarity.lowercased() }
        
        // Select commons
        if let commons = cardsByRarity["common"] {
            let count = Int(boosterComposition["common"] ?? 10)
            let selectedCommons = commons.shuffled().prefix(count)
            selectedCards.append(contentsOf: selectedCommons)
        }
        
        // Select uncommons
        if let uncommons = cardsByRarity["uncommon"] {
            let count = Int(boosterComposition["uncommon"] ?? 3)
            let selectedUncommons = uncommons.shuffled().prefix(count)
            selectedCards.append(contentsOf: selectedUncommons)
        }
        
        // Select rare or mythic
        let rareOrMythic = (cardsByRarity["rare"] ?? []) + (cardsByRarity["mythic"] ?? [])
        if !rareOrMythic.isEmpty {
            let selectedRare = rareOrMythic.shuffled().prefix(1)
            selectedCards.append(contentsOf: selectedRare)
        }
        
        return selectedCards.shuffled() // Shuffle the final order
    }
    
    func getCardValue(_ card: ScryfallCard) -> Double {
        // Get the USD price if available, otherwise return 0
        if let usdPrice = card.prices?.usd, let price = Double(usdPrice) {
            return price
        }
        return 0.0
    }
    
    func calculateBoosterValue(_ cards: [ScryfallCard]) -> Double {
        return cards.reduce(0.0) { total, card in
            total + getCardValue(card)
        }
    }
} 