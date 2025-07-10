//
//  BoosterKey.swift
//  BlackMagic
//
//  Created by Alex on 7/10/25.
//


struct BoosterKey: Hashable, Codable {
    let setCode: String
    let type: UserBooster.BoosterType
}
