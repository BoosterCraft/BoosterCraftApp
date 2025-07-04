import UIKit

class BoosterCardView: UIView {
    
    // MARK: - UI Elements
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buyButton = UIButton(type: .system)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        backgroundColor = .darkGray
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "default-booster") // placeholder image
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        buyButton.setTitle("BUY NOW", for: .normal)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        buyButton.backgroundColor = .black
        buyButton.layer.cornerRadius = 12
        buyButton.layer.borderWidth = 1
        buyButton.layer.borderColor = UIColor.white.cgColor
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(buyButton)
        
        imageView.pinTop(to: self.topAnchor, 16)
        imageView.pinLeft(to: self, 16)
        imageView.pinRight(to: self, 16)
        imageView.setHeight(mode: .equal, 200)
        
        titleLabel.pinTop(to: imageView.bottomAnchor, 12)
        titleLabel.pinLeft(to: self, 16)
        titleLabel.pinRight(to: self, 16)
        
        descriptionLabel.pinTop(to: titleLabel.bottomAnchor, 8)
        descriptionLabel.pinLeft(to: self, 16)
        descriptionLabel.pinRight(to: self, 16)
        
        buyButton.pinTop(to: descriptionLabel.bottomAnchor, 12)
        buyButton.pinLeft(to: self, 16)
        buyButton.pinRight(to: self, 16)
        buyButton.setHeight(mode: .equal, 50)
        buyButton.pinBottom(to: self, 16)
    }
    
    // MARK: - Configure
    
    func configure(with title: String) {
        titleLabel.text = title
        descriptionLabel.text = "Cinematic action, dynamic clan gameplay, and powerful new dragons that add lasting firepower to your collection."
    }
}
