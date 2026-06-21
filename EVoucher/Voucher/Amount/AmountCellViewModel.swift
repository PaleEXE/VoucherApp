//
//  AmountCellViewModel.swift
//  EVoucher
//
//  Created by test on 21/06/2026.
//

import RxSwift
import RxCocoa

class AmountCellViewModel {
    let value: BehaviorRelay<Int>
    let isSelected: BehaviorRelay<Bool>

    init(model: Amount, isSelected: Bool = false) {
        self.value = BehaviorRelay(value: model.value)
        self.isSelected = BehaviorRelay(value: isSelected)
    }
}
