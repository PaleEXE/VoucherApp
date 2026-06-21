import UIKit
import RxSwift
import RxCocoa

class AmountCell: UICollectionViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var mainView: BorderedView!
    
    var disposeBag = DisposeBag()

    var viewModel: AmountCellViewModel!

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        amountLabel.textAlignment = .center
    }

    func bind(to vm: AmountCellViewModel) {
        viewModel = vm

        viewModel.value
            .map( { "\($0)" })
            .asDriver(onErrorJustReturn: "SUI")
            .drive(amountLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isSelected
            .map({ $0 ? self.mainView.selectedColor : self.mainView.normalColor})
            .asDriver(onErrorJustReturn: .white)
            .drive(mainView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.isSelected
            .map({ $0 ? self.mainView.selectedBorderWidth : self.mainView.normalBorderWidth})
            .asDriver(onErrorJustReturn: 5)
            .drive(mainView.layer.rx.borderWidth)
            .disposed(by: disposeBag)
    }
}
