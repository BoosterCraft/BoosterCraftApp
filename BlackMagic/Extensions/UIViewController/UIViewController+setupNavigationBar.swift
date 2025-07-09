//
//  UIViewController.swift
//  BlackMagic
//
//  Created by Alex on 7/9/25.
//

import UIKit

extension UIViewController {
    func setupNavigationBar(_ balanceButton: UIButton, title navigationTitle: String) {
        let accessoryView = balanceButton
        accessoryView.frame.size = CGSize(width: 50, height: 34)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.setLargeTitleAccessoryView(with: accessoryView)
        title = navigationTitle

        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular", size: 40) ?? UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }

        view.backgroundColor = .black
    }
}
