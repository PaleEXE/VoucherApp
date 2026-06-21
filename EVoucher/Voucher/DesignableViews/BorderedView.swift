import UIKit

@IBDesignable
class BorderedView : UIView {
    @IBInspectable var cornerRadius: CGFloat = 16 {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var normalBorderWidth: CGFloat = 1 {
        didSet { layer.borderWidth = normalBorderWidth }
    }

    @IBInspectable var selectedBorderWidth: CGFloat = 2

    @IBInspectable var normalColor: UIColor = .secondary
    @IBInspectable var selectedColor: UIColor = .primary

    @IBInspectable var borderColor: UIColor = .text {
        didSet { layer.borderColor = borderColor.cgColor }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = normalBorderWidth
        layer.borderColor = borderColor.cgColor
        backgroundColor = normalColor
    }
}
