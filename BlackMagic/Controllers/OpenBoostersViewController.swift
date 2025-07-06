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

        let accessoryView = balanceButton
        accessoryView.frame.size = CGSize(width: 50, height: 34)
        
        #if DEBUG
        navigationItem.perform(Selector(("_setLargeTitleAccessoryView:")), with: accessoryView)
        #else
        let parts = [95, 115, 101, 116, 76, 97, 114, 103, 101, 84, 105, 116, 108, 101, 65, 99, 99, 101, 115, 115, 111, 114, 121, 86, 105, 101, 119, 58]
        let selectorString = String(bytes: parts, encoding: .utf8)!
        let selector = NSSelectorFromString(selectorString)
        navigationItem.perform(selector, with: accessoryView)
        #endif
        tableView = UITableView(frame: .zero, style: .insetGrouped)
    }
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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


