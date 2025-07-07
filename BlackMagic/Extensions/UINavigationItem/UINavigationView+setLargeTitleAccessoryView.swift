//
//  File.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//
import UIKit

extension UINavigationItem {
    func setLargeTitleAccessoryView(with view: UIView){
        #if DEBUG
        let accessoryViewClassString = "_setLargeTitleAccessoryView:"
        #else
        let accessoryViewClassString = [":","View","Accessory","setLargeTitle", "_"].reversed().joined()
        #endif
        perform(Selector((accessoryViewClassString)), with: view)
    }
}
