import UIKit

final class OpenBoosterCardView: UIView {
    
    private let frontView = UIView()
    private let backView = UIView()
    
    private let setLabel = UILabel()
    private let typeLabel = UILabel()
    private let boosterLabel = UILabel()
    
    private let badgeLabel = UILabel()  // badge moved to self
    
    var onOpenTapped: (() -> Void)?
//    private let backTextLabel = UILabel()
    private let openButton = UIButton()
    private let closeButton = UIButton()
    private let backStackView = UIStackView()
    
    private var isFrontVisible = true
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = false  // <- allow badge to overflow
        
        setupFront()
        setupBack()
        
        addSubview(frontView)
        addSubview(backView)
        addSubview(badgeLabel) // badge added to self, not frontView
        
        frontView.pin(to: self)
        backView.pin(to: self)
        backView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        addGestureRecognizer(tap)
        
        setupBadge()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    private func setupFront() {
        frontView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        frontView.layer.cornerRadius = 16
        frontView.clipsToBounds = true
        
        [setLabel, typeLabel, boosterLabel].forEach {
            frontView.addSubview($0)
        }
        
        setLabel.font = UIFont.boldSystemFont(ofSize: 14)
        setLabel.textColor = .white
        setLabel.textAlignment = .center
        setLabel.backgroundColor = .systemBlue
        setLabel.layer.cornerRadius = 8
        setLabel.clipsToBounds = true
        
        typeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        typeLabel.textColor = .white
        typeLabel.textAlignment = .center
        
        boosterLabel.font = UIFont.systemFont(ofSize: 14)
        boosterLabel.textColor = .lightGray
        boosterLabel.textAlignment = .center
        
        setLabel.pinTop(to: frontView, 8)
        setLabel.pinLeft(to: frontView, 8)
        setLabel.pinRight(to: frontView, 8)
        setLabel.setHeight(24)
        
        typeLabel.pinTop(to: setLabel.bottomAnchor, 16)
        typeLabel.pinLeft(to: frontView, 8)
        typeLabel.pinRight(to: frontView, 8)
        
        boosterLabel.pinTop(to: typeLabel.bottomAnchor, 4)
        boosterLabel.pinLeft(to: frontView, 8)
        boosterLabel.pinRight(to: frontView, 8)
    }
    
    private func setupBack() {
        backView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        backView.layer.cornerRadius = 16
        backView.clipsToBounds = true
        
//        backTextLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        backTextLabel.textColor = .white
//        backTextLabel.numberOfLines = 0
//        backTextLabel.textAlignment = .center
//        backTextLabel.text = "Back side.\nTap to flip."
        
        
        openButton.setTitle("Open", for: .normal)
        openButton.setTitleColor(.white, for: .normal)
        openButton.backgroundColor = UIColor(named: "openColor") ?? .systemBlue
        openButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        openButton.layer.cornerRadius = 14
        openButton.addTarget(self, action: #selector(handleOpenTap), for: .touchUpInside)
        
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemGray, for: .normal)
//        closeButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.layer.cornerRadius = 14
        closeButton.addTarget(self, action: #selector(flipCard), for: .touchUpInside)
        
//        backView.addSubview(backTextLabel)
        backStackView.axis = .vertical
        backStackView.spacing = 12
        backStackView.alignment = .center
        backStackView.distribution = .equalSpacing

        backStackView.addArrangedSubview(openButton)
        backStackView.addArrangedSubview(closeButton)
        
        backView.addSubview(backStackView)
        // constraints
        backStackView.pinCenterX(to: backView.centerXAnchor)
        backStackView.pinCenterY(to: backView.centerYAnchor)
        
        openButton.setHeight(50)
        openButton.setWidth(82)
        
        closeButton.setHeight(44)
        closeButton.setWidth(80)
    }
    
    private func setupBadge() {
        badgeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = .systemBlue
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
        badgeLabel.layer.borderWidth = 2
        badgeLabel.layer.borderColor = UIColor.black.cgColor
        
        // Size & position: bottom-right overhanging by 8pt
        badgeLabel.setWidth(24)
        badgeLabel.setHeight(24)
        badgeLabel.pinBottom(to: self, -8)
        badgeLabel.pinRight(to: self, -8)
    }
    
    // MARK: - Public Configuration
    /// Конфигурирует отображение бустера (цвет и цвет текста для setLabel)
    func configure(set: String, type: String, count: Int, color: UIColor, textColor: UIColor) {
        setLabel.text = set
        setLabel.backgroundColor = color
        setLabel.textColor = textColor // Цвет текста для setLabel
        typeLabel.text = type
        boosterLabel.text = "booster"
        badgeLabel.text = "\(count)"
        badgeLabel.alpha = 1
        badgeLabel.transform = .identity
        badgeLabel.isHidden = (count == 0)
    }
    
    // MARK: - Flip Animation
    
    @objc private func flipCard() {
        let fromView = isFrontVisible ? frontView : backView
        let toView = isFrontVisible ? backView : frontView
        
        if isFrontVisible {
            UIView.animate(withDuration: 0.3, animations: {
                self.badgeLabel.alpha = 0
                self.badgeLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                self.badgeLabel.alpha = 1
                self.badgeLabel.transform = .identity
            }, completion: nil)
        }
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.5,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: nil)
        
        isFrontVisible.toggle()
    }
    @objc private func handleOpenTap() {
        onOpenTapped?()
    }
}

