//
//  UIView+addSubviews.swift
//  BlackMagic
//
//  Created by Alex on 7/4/25.
//

import UIKit

extension UIView {
    /*
     For adding many subviews
     Example:
     UIView.addSubviews(view1, view2, view3)
     */
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
