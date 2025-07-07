//
//  OpenBoostersViewController.swift
//  BlackMagic
//
//  Created by Alex on 7/6/25.
//

import UIKit

final class OpenBoostersViewController: UITableViewController {
    private let balanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("$47.92", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let accessoryView = balanceButton
        accessoryView.frame.size = CGSize(width: 50, height: 34)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.setLargeTitleAccessoryView(with: accessoryView)
        title = "Open boosters"
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.largeTitleTextAttributes = [
                .font: UIFont(name: "PirataOne-Regular" , size: 40),
                .foregroundColor: UIColor.white
            ]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
    }
}


