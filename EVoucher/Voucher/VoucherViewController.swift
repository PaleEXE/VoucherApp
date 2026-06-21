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
    @IBOutlet weak var NumberVoucherStackView: UIStackView!
    @IBOutlet weak var AmountLabel: UILabel!

    let viewModel = VoucherViewModel()
    let disposeBag = DisposeBag()
    let numberPickerView = UIPickerView()
    let customDoneBtn = BorderedButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "E-Voucher"
        setupUI()
    }

    private func setupTapToClose() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .filter { [weak self] gesture in
                guard let self = self else { return false }

                let touchLocation = gesture.location(in: self.view)
                return !self.numberPickerView.frame.contains(touchLocation)
            }
            .bind(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
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
        setupTapToClose()
    }

    private func setupScrollView() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
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
        setupDoneToolbar()
    }

    private func setupDoneToolbar() {
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.baseBackgroundColor = UIColor(named: "primary")
        config.baseForegroundColor = UIColor(named: "text")

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

        viewModel.selectedOperator
            .subscribe(onNext: { [weak self] value in
                self?.NumberVoucherStackView.isHidden = value?.name != "Abdo"
            })
            .disposed(by: disposeBag)
    }

    private func bindNumberPicker() {
        viewModel.selectedNumberVouchers
            .map({ $0 != nil ? "\($0!)" : "1" })
            .asDriver(onErrorJustReturn: "SUI")
            .drive(vouchersNumberPicker.rx.text)
            .disposed(by: disposeBag)


        viewModel.numberVouchers
            .bind(to: numberPickerView.rx.itemAttributedTitles) { _, item in
                NSAttributedString(
                    string: "\(item)",
                    attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .bold)]
                )
            }
            .disposed(by: disposeBag)

        numberPickerView.rx.modelSelected(Int.self)
            .map { $0.first }
            .compactMap { $0 }
            .bind(to: viewModel.selectedNumberVouchers)
            .disposed(by: disposeBag)
    }

    private func bindOperatorsCollectionView() {
        viewModel.operators
            .bind(to: operatorsCollectionView.rx.items(
                cellIdentifier: "OperatorCell",
                cellType: OperatorCell.self
            )) { _, op, cell in
                let vm = OperatorCellViewModel(model: op)
                cell.bind(to: vm)
            }
            .disposed(by: disposeBag)

        operatorsCollectionView.rx.modelSelected(Operator.self)
            .subscribe(onNext: { [weak self] tappedOperator in
                self?.viewModel.selectedOperator.accept(tappedOperator)
            })
            .disposed(by: disposeBag)
    }

    private func bindAmountCollectionView() {
        viewModel.amounts
            .bind(to: voucherAmountCollectionView.rx.items(
                cellIdentifier: "AmountCell",
                cellType: AmountCell.self
            )) { [weak self] _, amount, cell in
                guard let self else { return }
                let vm = AmountCellViewModel(model: amount)
                cell.bind(to: vm)

                let isSelected = self.viewModel.selectedAmount.value?.value == amount.value
                vm.isSelected.accept(isSelected)

                self.viewModel.selectedAmount
                    .map { $0?.value == amount.value }
                    .distinctUntilChanged()
                    .bind(to: vm.isSelected)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        voucherAmountCollectionView.rx.itemSelected
            .map { [weak self] indexPath -> Amount? in
                self?.viewModel.amounts.value[indexPath.row]
            }
            .compactMap { $0 }
            .withLatestFrom(viewModel.selectedAmount) { tapped, current in
                current?.value == tapped?.value ? nil : tapped
            }
            .bind(to: viewModel.selectedAmount)
            .disposed(by: disposeBag)

        viewModel.operators
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateCollectionViewHeight()
            })
            .disposed(by: disposeBag)

        viewModel.selectedAmount
            .map({ $0 != nil ? "\($0!.value)" : ""})
            .asDriver(onErrorJustReturn: "ERR")
            .drive(AmountLabel.rx.text)
            .disposed(by: disposeBag)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
