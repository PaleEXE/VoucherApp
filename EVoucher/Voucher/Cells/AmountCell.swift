import UIKit

class AmountCell: UICollectionViewCell {
    @IBOutlet weak var amountLabel: UILabel!

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

        amountLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        amountLabel.textAlignment = .center

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
}
