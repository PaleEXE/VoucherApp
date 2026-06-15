import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class OperatorCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    private let disposeBag = DisposeBag()

    let isSelectedRelay = BehaviorRelay<Bool>(value: false)

    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var selectedBorderWidth: CGFloat = 2
    @IBInspectable var normalBorderWidth: CGFloat = 0

    @IBInspectable var selectedColor: UIColor = .primary
    @IBInspectable var normalColor: UIColor = .secondary

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
        bindUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = cornerRadius
    }

    private func bindUI() {
        isSelectedRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isSelected in
                guard let self = self else { return }

                self.contentView.backgroundColor = isSelected
                    ? self.selectedColor
                    : self.normalColor

                self.contentView.layer.borderWidth = isSelected
                    ? self.selectedBorderWidth
                    : self.normalBorderWidth

                self.contentView.layer.borderColor = isSelected
                    ? UIColor.label.cgColor
                    : nil
            })
            .disposed(by: disposeBag)
    }

    func setSelected(_ selected: Bool) {
        isSelectedRelay.accept(selected)
    }

    func configure(with item: Operator) {
        imageView.image = item.logo
        nameLabel.text = item.name
    }
}
