import UIKit

class BoosterCardCell: UICollectionViewCell {
    
    static let cellId = "BoosterCardCell"
    
    private var boosterCardView: BoosterCardView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        clipsToBounds = false         // allow shadows outside bounds
        contentView.clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with boosterCardView: BoosterCardView) {
        // Remove previous if any
        self.boosterCardView?.removeFromSuperview()
        
        self.boosterCardView = boosterCardView
        contentView.addSubview(boosterCardView)
        
        boosterCardView.pin(to: contentView)
    }
}
