import UIKit
import RxSwift
import RxCocoa

struct Operator {
    let name: String
    let logo: UIImage

    init(name: String, logoPath: String) {
        self.logo = UIImage(named: logoPath) ?? UIImage()
        self.name = name
    }
}

class VoucherModelView {
    let operators = BehaviorRelay<[Operator]>(value: [
        Operator(name: "Patata", logoPath: "patata"),
        Operator(name: "Banana", logoPath: "banana"),
        Operator(name: "Ananas", logoPath: "ananas"),
        Operator(name: "Matata", logoPath: "matata")
    ])
    let amounts = BehaviorRelay<[Int]>(value: Array(1...20).map { $0 * 10 })
    let numberVouchers = BehaviorRelay<[Int]>(value: Array(1...10))

    let selectedOperator = BehaviorRelay<Operator?>(value: nil)
    let selectedAmount = BehaviorRelay<Int?>(value: nil)
    let selectedNumberVouchers = BehaviorRelay<Int?>(value: nil)

    let isValid: Observable<Bool>

    let disposeBag = DisposeBag()

    init() {
        isValid = Observable
            .combineLatest(selectedOperator, selectedAmount, selectedNumberVouchers)
            .map { op, amount, vouchers in
                return op != nil && amount != nil && vouchers != nil
            }
    }
}
