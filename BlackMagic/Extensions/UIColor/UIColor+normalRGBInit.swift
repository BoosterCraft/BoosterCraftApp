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
}
