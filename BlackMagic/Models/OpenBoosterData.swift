//
//  OpenBoosterData.swift
//  BlackMagic
//
//  Created by Мирон Лабус on 07.07.2025.
//
import UIKit

// Модель для неоткрытого бустера пользователя
struct UserBooster: Codable {
    enum BoosterType: String, Codable {
        case play = "Play"
        case collector = "Collector"
    }
    // Код сета (например, "TDM")
    let setCode: String
    // Тип бустера (Play или Collector)
    let type: BoosterType
    // Цвет бустера (опционально, по умолчанию nil)
    let colorHex: String?
    // Уникальный идентификатор бустера (для удаления/открытия)
    let id: UUID
    
    // Инициализация с опциональным цветом
    init(setCode: String, type: BoosterType, color: UIColor? = nil) {
        self.setCode = setCode
        self.type = type
        self.colorHex = color?.toHexString()
        self.id = UUID()
    }
}


