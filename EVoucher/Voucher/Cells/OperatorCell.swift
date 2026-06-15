import UIKit

class OperatorCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(named: "primary") : UIColor(named: "secondary")
            contentView.layer.borderWidth = isSelected ? 2 : 0
            updateBorderColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear
        contentView.backgroundColor = UIColor(named: "secondary")
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true

        // iOS 17+ Theme Listener
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], action: #selector(updateBorderColor))
        }
    }

    @objc private func updateBorderColor() {
        if isSelected {
            contentView.layer.borderColor = UIColor(named: "text")?.cgColor
        }
    }

    // Fallback for iOS 16 and older
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 17.0, *) {
            // Handled by registerForTraitChanges
        } else {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateBorderColor()
            }
        }
    }

    func configure(with item: Operator) {
        imageView?.image = item.logo
        nameLabel?.text = item.name
    }
}
