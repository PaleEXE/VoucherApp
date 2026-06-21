//
//  OperatorCellViewModel.swift
//  EVoucher
//
//  Created by test on 21/06/2026.
//

import UIKit
import RxSwift
import RxCocoa

class OperatorCellViewModel {
    let name: BehaviorRelay<String?>
    let logo: BehaviorRelay<UIImage?>
    let isSelected: BehaviorRelay<Bool>

    init(model: Operator, isSelected: Bool = false) {
        self.name = BehaviorRelay<String?>(value: model.name)
        self.logo = BehaviorRelay<UIImage?>(value: model.logo)
        self.isSelected = BehaviorRelay<Bool>(value: isSelected)
    }
}
