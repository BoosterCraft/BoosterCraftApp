//
//  OpenBoosterData.swift
//  BlackMagic
//
//  Created by Мирон Лабус on 07.07.2025.
//
import UIKit
struct BoosterBought {
    let set: String
    let type: String
    let count: Int
    let color: UIColor
}

let boosterData: [BoosterBought] = [
    BoosterBought(set: "TDM", type: "Play", count: 2, color: .systemTeal),
    BoosterBought(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
    BoosterBought(set: "WOE", type: "Draft", count: 3, color: .purple),
    BoosterBought(set: "NEO", type: "SET", count: 2, color: .systemPink),
    BoosterBought(set: "ABC", type: "Play", count: 4, color: .systemGreen)
]
