//
//  MapNavigatorViewController.swift
//  black_magic_playground
//
//  Created by Alex on 7/3/25.
//

import UIKit

class CardViewController: UIViewController {
    
    let cardTitleText : String
    let cardTitleColor : UIColor
    let descriptionText : String
    let cardTitleBGColor : UIColor
    let imageURL : URL? // unused
    
    init(cardTitleText: String, cardTitleColor: UIColor, descriptionText: String, cardTitleBGColor: UIColor, imageURL : URL) {
        self.cardTitleText = cardTitleText
        self.cardTitleColor = cardTitleColor
        self.descriptionText =  descriptionText
        self.cardTitleBGColor =  cardTitleBGColor
        self.imageURL =  imageURL
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let cardImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "cardImage"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        //        image.layer.cornerRadius = 12
        return image
    }()
    
    private let cardTitle: UILabel = {
        let label = UILabel()
        label.text = "Card Title"
        label.textColor =  .systemBackground
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let cardDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private let cardButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true // Required
        button.setTitle("Buy now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let cardTitleBG: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 8
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        //        view.backgroundColor = .secondarySystemBackground
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
    }

    
    private func setupViews() {
        view.addSubviews(cardImage, cardTitleBG, cardTitle, cardDescription, cardButton)
        // MARK: Заголовок
        cardTitle.text = cardTitleText
        cardTitle.textColor = cardTitleColor
        // MARK: Описание
        cardDescription.text = descriptionText
        
        // MARK: Фон под текстом
        cardTitleBG.backgroundColor = cardTitleBGColor
        // MARK: Кнопка
        cardButton.setTitleColor(cardTitleColor, for: .normal)
        cardButton.backgroundColor = cardTitleBGColor
    }
    
    private func setupConstraints() {
        cardImage.setWidth(UIScreen.main.bounds.size.width)
        cardImage.setHeight(200)
        cardImage.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 40)
        cardImage.pinCenterX(to: view.centerXAnchor)
        
        // Фон заголовка
        cardTitleBG.pinTop(to: cardImage.bottomAnchor)
        cardTitleBG.pinCenterX(to: view.centerXAnchor)
        cardTitleBG.setHeight(40)
        cardTitleBG.pinWidth(to: cardTitle.widthAnchor, 40) // +20 с каждой стороны
        
        // Заголовок (внутри фона)
        cardTitle.pinCenter(to: cardTitleBG)
        
        // Основной текст
        cardDescription.pinTop(to: cardTitleBG.bottomAnchor, 20)
        cardDescription.pinLeft(to: view.leadingAnchor, 20)
        cardDescription.pinRight(to: view.trailingAnchor, 20)
        
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        
        cardDescription.pinLeft(to: view.leadingAnchor, 20)
        cardDescription.pinRight(to: view.trailingAnchor, 20)
        cardButton.pinTop(to: cardDescription.bottomAnchor, 20)
        cardButton.setWidth(UIScreen.main.bounds.size.width - 20)
        
        cardButton.pinCenter(to: cardButton)
        cardButton.setHeight(50)
        
    }
}
