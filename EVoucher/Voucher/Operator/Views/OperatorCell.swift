import UIKit
import RxSwift
import RxCocoa

class OperatorCell: UICollectionViewCell {

    @IBOutlet weak var mainView: BorderedView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var disposeBag = DisposeBag()
    var viewModel: OperatorCellViewModel!

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageView.image = nil
    }

    func bind(to vm: OperatorCellViewModel) {
        viewModel = vm

        viewModel.name
            .asDriver(onErrorJustReturn: "")
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.logo
            .asDriver(onErrorJustReturn: UIImage())
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.isSelected
            .map({ $0 ? self.mainView.selectedColor : self.mainView.normalColor })
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .purple)
            .drive(mainView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.isSelected
            .map({ $0 ? self.mainView.selectedBorderWidth : self.mainView.normalBorderWidth})
            .asDriver(onErrorJustReturn: 5)
            .drive(mainView.layer.rx.borderWidth)
            .disposed(by: disposeBag)

    }
}
