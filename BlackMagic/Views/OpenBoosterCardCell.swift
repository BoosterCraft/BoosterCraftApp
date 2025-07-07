import UIKit

final class OpenBoosterCardCell: UICollectionViewCell {
    static let identifier = "OpenBoosterCardCell"

    let cardView = OpenBoosterCardView()
    var onOpenTapped: (() -> Void)? {
           didSet {
               cardView.onOpenTapped = onOpenTapped
           }
       }
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.addSubview(cardView)
        cardView.pin(to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
