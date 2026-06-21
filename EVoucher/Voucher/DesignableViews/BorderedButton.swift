import UIKit

@IBDesignable
class BorderedButton : UIButton {
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.masksToBounds = true
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet { layer.borderWidth = borderWidth }
    }

    @IBInspectable var borderColor: UIColor = .text {
        didSet { layer.borderColor = borderColor.cgColor }
    }
}
