//
//  OpenBoosterData.swift
//  BlackMagic
//
//  Created by Мирон Лабус on 07.07.2025.
//
import UIKit
struct Booster {
    let set: String
    let type: String
    let count: Int
    let color: UIColor
}

let boosterData: [Booster] = [
    Booster(set: "TDM", type: "Play", count: 2, color: .systemTeal),
    Booster(set: "OTJ", type: "Collector", count: 1, color: .systemOrange),
    Booster(set: "WOE", type: "Draft", count: 3, color: .purple),
    Booster(set: "NEO", type: "SET", count: 2, color: .systemPink),
    Booster(set: "ABC", type: "Play", count: 4, color: .systemGreen)
]
