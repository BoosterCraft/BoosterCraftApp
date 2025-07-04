import UIKit

class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Black magic"
        label.font = UIFont(name: "Chalkduster", size: 34)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let balanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("$47.92", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        let icon = UIImage(systemName: "creditcard.fill")
        button.setImage(icon, for: .normal)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return button
    }()
    
    private let boosterScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.numberOfPages = 3
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .darkGray
        return pageControl
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupScrollViewContent()
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(balanceButton)
        view.addSubview(boosterScrollView)
        view.addSubview(pageControl)
        
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(to: view)
        
        balanceButton.pinTop(to: titleLabel.bottomAnchor, 8)
        balanceButton.pinCenterX(to: view)
        
        boosterScrollView.pinTop(to: balanceButton.bottomAnchor, 32)
        boosterScrollView.pinLeft(to: view)
        boosterScrollView.pinRight(to: view)
        boosterScrollView.pinHeight(to: view.heightAnchor, 0.6)
        
        pageControl.pinTop(to: boosterScrollView.bottomAnchor, 16)
        pageControl.pinCenterX(to: view)
        
        boosterScrollView.delegate = self
    }
    
    private func setupScrollViewContent() {
        let cardWidth = view.frame.width * 0.85
        let padding: CGFloat = 16
        
        let boosterSets = [
            "TARKIR: DRAGONSTORM",
            "INNISTRAD: MOONRISE",
            "RAVNICA: CHAOS"
        ]
        
        for (index, setName) in boosterSets.enumerated() {
            let cardView = BoosterCardView()
            cardView.configure(with: setName)
            boosterScrollView.addSubview(cardView)
            
            cardView.setWidth( mode: .equal, Double(cardWidth))
            cardView.pinHeight(to: boosterScrollView.heightAnchor)
            cardView.pinTop(to: boosterScrollView.topAnchor)
            
            if index == 0 {
                cardView.pinLeft(to: boosterScrollView, Double(padding))
            } else {
                let previousCard = boosterScrollView.subviews[index - 1]
                cardView.pinLeft(to: previousCard.trailingAnchor, Double(padding))
            }
        }
        
        if let lastCard = boosterScrollView.subviews.last {
            lastCard.pinRight(to: boosterScrollView, Double(padding))
        }
    }
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = view.frame.width * 0.85 + 16
        let currentPage = Int((scrollView.contentOffset.x + (0.5 * pageWidth)) / pageWidth)
        pageControl.currentPage = currentPage
    }
}
