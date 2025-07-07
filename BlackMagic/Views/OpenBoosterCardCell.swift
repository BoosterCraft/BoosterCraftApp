import UIKit

final class OpenBoosterCardCell: UICollectionViewCell {
    static let identifier = "OpenBoosterCardCell"

    let cardView = OpenBoosterCardView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView)
        cardView.pin(to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
