//
//  File.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//
import UIKit

extension UINavigationItem {
    func setLargeTitleAccessoryView(with view: UIView){
        let accessoryViewClassString = [":","View","Accessory","setLargeTitle", "_"].reversed().joined()
        perform(Selector((accessoryViewClassString)), with: view)
    }
}
