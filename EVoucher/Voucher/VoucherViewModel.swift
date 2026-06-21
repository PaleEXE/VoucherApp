import UIKit
import RxSwift
import RxCocoa

class VoucherViewModel {
    let operators = BehaviorRelay<[Operator]>(value: [
        Operator(name: "Patata", logoPath: "patata"),
        Operator(name: "Banana", logoPath: "banana"),
        Operator(name: "Ananas", logoPath: "ananas"),
        Operator(name: "Matata", logoPath: "matata"),
        Operator(name: "Abdo", logoPath: "abdo"),
        Operator(name: "Achilles", logoPath: "Image 1"),
        Operator(name: "Aphrodite", logoPath: "Image 2"),
        Operator(name: "Ares", logoPath: "Image 3"),
        Operator(name: "Artemis", logoPath: "Image 4"),
        Operator(name: "Athena", logoPath: "Image 5"),
        Operator(name: "Cerberus", logoPath: "Image 6"),
        Operator(name: "Chaos", logoPath: "Image 7"),
        Operator(name: "Charon", logoPath: "Image 8"),
        Operator(name: "Demeter", logoPath: "Image 9"),
        Operator(name: "Dionysus", logoPath: "Image 10"),
        Operator(name: "Dusa", logoPath: "Image 11"),
        Operator(name: "Eurydice", logoPath: "Image 12"),
        Operator(name: "Hades", logoPath: "Image 13"),
        Operator(name: "Hermes", logoPath: "Image 14"),
        Operator(name: "Hypnos", logoPath: "Image 15"),
        Operator(name: "Megaera", logoPath: "Image 16"),
        Operator(name: "Nyx", logoPath: "Image 17"),
        Operator(name: "Orpheus", logoPath: "Image 18"),
    ])
    let amounts = BehaviorRelay<[Amount]>(value: Array(1...20).map { Amount(value: $0 * 10) })
    let numberVouchers = BehaviorRelay<[Int]>(value: Array(1...10))

    let tappedOperator = BehaviorRelay<Operator?>(value: nil)
    let selectedOperator = BehaviorRelay<Operator?>(value: nil)
    let selectedAmount = BehaviorRelay<Amount?>(value: nil)
    let selectedNumberVouchers = BehaviorRelay<Int?>(value: 1)

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
