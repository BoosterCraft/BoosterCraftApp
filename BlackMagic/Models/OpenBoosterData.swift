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

// MARK: - Вспомогательное расширение для UIColor <-> Hex
extension UIColor {
    // Преобразовать UIColor в hex-строку
    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
    // Создать UIColor из hex-строки
    static func fromHexString(_ hex: String) -> UIColor? {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.removeFirst() }
        guard cString.count == 6 else { return nil }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

// Массив неоткрытых бустеров пользователя
struct UserBoosters: Codable {
    var boosters: [UserBooster]
}

extension UserBoosters {
    // Группировка бустеров по (setCode, type) с подсчетом количества
    func groupedCounts() -> [BoosterKey: Int] {
        var dict: [BoosterKey: Int] = [:]
        for booster in boosters {
            let key = BoosterKey(setCode: booster.setCode, type: booster.type)
            dict[key, default: 0] += 1
        }
        return dict
    }
}

// Ключ для группировки бустеров (сет + тип)
struct BoosterKey: Hashable, Codable {
    let setCode: String
    let type: UserBooster.BoosterType
}
