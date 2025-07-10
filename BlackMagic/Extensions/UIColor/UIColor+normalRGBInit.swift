//
//  UIColor+normalRGBInit.swift
//  BlackMagic
//
//  Created by Alex on 7/5/25.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            alpha: 1.0
        )
    }

    /// Возвращает цвет для бейджа в зависимости от редкости карты Scryfall
    /// - Parameter rarity: строка редкости (например, "common", "uncommon", "rare", "mythic")
    /// - Returns: UIColor для бейджа
    static func badgeColor(forRarity rarity: String?) -> UIColor {
        guard let rarity = rarity?.lowercased() else {
            // Серый по умолчанию
            return UIColor(red: 180, green: 180, blue: 180)
        }
        switch rarity {
        case "common":
            return UIColor(red: 85, green: 180, blue: 120) // Серый
        case "uncommon":
            return UIColor(red: 160, green: 160, blue: 160) // Зеленый
        case "rare":
            return UIColor(red: 255, green: 215, blue: 0) // Золотой
        case "mythic":
            return UIColor(red: 255, green: 85, blue: 0) // Оранжево-красный
        default:
            return UIColor(red: 120, green: 120, blue: 120) // Серый для неизвестных
        }
    }
}
