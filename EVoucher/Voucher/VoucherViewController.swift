import UIKit
import RxSwift
import RxCocoa

class VoucherViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var paymentButton: BorderedButton!
    @IBOutlet weak var operatorsCollectionView: UICollectionView!
    @IBOutlet weak var vouchersNumberPicker: UITextField!
    @IBOutlet weak var voucherAmountCollectionView: UICollectionView!
    @IBOutlet weak var submitOrderButton: BorderedButton!

    @IBOutlet weak var amountHeightConstraint: NSLayoutConstraint!

    let viewModel = VoucherModelView()
    let disposeBag = DisposeBag()
    let numberPickerView = UIPickerView()
    let customDoneBtn = BorderedButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "E-Voucher"
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureOperatorsCollectionViewLayout()
    }

    private func setupUI() {
        setupScrollView()
        setupCollectionViews()
        setupNumberPicker()
        setupAmountCollectionViewLayout()
        setupBindings()
        viewModel.isValid
            .subscribe(onNext: { print("VALID:", $0) })
            .disposed(by: disposeBag)
    }

    private func setupScrollView() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }

    private func setupCollectionViews() {
        operatorsCollectionView.showsHorizontalScrollIndicator = false
        voucherAmountCollectionView.showsHorizontalScrollIndicator = false

        operatorsCollectionView.register(
            UINib(nibName: "OperatorCell", bundle: nil),
            forCellWithReuseIdentifier: "OperatorCell"
        )
        voucherAmountCollectionView.register(
            UINib(nibName: "AmountCell", bundle: nil),
            forCellWithReuseIdentifier: "AmountCell"
        )
    }

    private func configureOperatorsCollectionViewLayout() {
        guard let layout = operatorsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: operatorsCollectionView.bounds.height)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }

    private func updateCollectionViewHeight() {
        voucherAmountCollectionView.layoutIfNeeded()
        amountHeightConstraint.constant = voucherAmountCollectionView.collectionViewLayout.collectionViewContentSize.height
        view.layoutIfNeeded()
    }

    private func setupAmountCollectionViewLayout() {
        guard let layout = voucherAmountCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let columns: CGFloat = 4
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (columns - 1)
        let availableWidth = voucherAmountCollectionView.bounds.width - totalSpacing
        let cellWidth = floor(availableWidth / columns)

        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = CGSize(width: cellWidth, height: 50)

        voucherAmountCollectionView.isScrollEnabled = false
    }

    private func setupNumberPicker() {
        vouchersNumberPicker.inputView = numberPickerView
        vouchersNumberPicker.tintColor = .clear
        vouchersNumberPicker.textAlignment = .center
        vouchersNumberPicker.applyBorderedStyle(cornerRadius: 8)
        setupDoneToolbar()
    }

    private func setupDoneToolbar() {
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.baseBackgroundColor = UIColor(named: "primary")
        config.baseForegroundColor = UIColor(named: "text")
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

        customDoneBtn.configuration = config
        customDoneBtn.cornerRadius = 8
        customDoneBtn.borderWidth = 2
        customDoneBtn.borderColor = UIColor(named: "text") ?? .label
        customDoneBtn.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBarButton = UIBarButtonItem(customView: customDoneBtn)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacer, doneBarButton], animated: false)

        vouchersNumberPicker.inputAccessoryView = toolbar
    }

    private func setupBindings() {
        bindNumberPicker()
        bindOperatorsCollectionView()
        bindAmountCollectionView()

        viewModel.isValid
            .bind(to: submitOrderButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func bindNumberPicker() {
        if let firstQuantity = viewModel.numberVouchers.value.first {
            vouchersNumberPicker.text = "\(firstQuantity)"
            viewModel.selectedNumberVouchers.accept(firstQuantity)
        }

        viewModel.numberVouchers
            .bind(to: numberPickerView.rx.itemAttributedTitles) { _, item in
                NSAttributedString(
                    string: "\(item)",
                    attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .bold)]
                )
            }
            .disposed(by: disposeBag)

        numberPickerView.rx.itemSelected
            .bind(onNext: { [weak self] row, _ in
                guard let self else { return }
                let value = self.viewModel.numberVouchers.value[row]
                self.vouchersNumberPicker.text = "\(value)"
                self.viewModel.selectedNumberVouchers.accept(value)
            })
            .disposed(by: disposeBag)
    }

    private func bindOperatorsCollectionView() {
        viewModel.operators
            .bind(to: operatorsCollectionView.rx.items(
                cellIdentifier: "OperatorCell",
                cellType: OperatorCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        operatorsCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let op = self.viewModel.operators.value[indexPath.item]
                self.viewModel.selectedOperator.accept(op)

                self.operatorsCollectionView.visibleCells
                    .compactMap { $0 as? OperatorCell }
                    .forEach { cell in
                        let cellIndex = self.operatorsCollectionView.indexPath(for: cell)?.item
                        cell.setSelected(cellIndex == indexPath.item)
                    }
            })
            .disposed(by: disposeBag)
    }

    private func bindAmountCollectionView() {
        viewModel.amounts
            .bind(to: voucherAmountCollectionView.rx.items(
                cellIdentifier: "AmountCell",
                cellType: AmountCell.self
            )) { _, amount, cell in
                cell.configure(amount: "\(amount)")
            }
            .disposed(by: disposeBag)

        voucherAmountCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self else { return }
                let amount = self.viewModel.amounts.value[indexPath.item]
                self.viewModel.selectedAmount.accept(amount)

                self.voucherAmountCollectionView.visibleCells
                    .compactMap { $0 as? AmountCell }
                    .forEach { cell in
                        let cellIndex = self.voucherAmountCollectionView.indexPath(for: cell)?.item
                        cell.setSelected(cellIndex == indexPath.item)
                    }
            })
            .disposed(by: disposeBag)

        viewModel.operators
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateCollectionViewHeight()
            })
            .disposed(by: disposeBag)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

@IBDesignable
class BorderedButton: UIButton {

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

    @IBInspectable var fillColor: UIColor = .clear {
        didSet { backgroundColor = fillColor }
    }
}

extension UIView {
    func applyBorderedStyle(
        borderWidth: CGFloat = 2,
        cornerRadius: CGFloat = 10,
        borderColor: UIColor? = UIColor(named: "text")
    ) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderColor = borderColor?.cgColor
    }
}
