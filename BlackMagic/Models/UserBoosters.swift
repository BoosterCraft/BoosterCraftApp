//
//  UserBoosters.swift
//  BlackMagic
//
//  Created by Alex on 7/10/25.
//


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
