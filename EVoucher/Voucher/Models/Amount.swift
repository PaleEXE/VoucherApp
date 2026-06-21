//
//  Amount.swift
//  EVoucher
//
//  Created by test on 21/06/2026.
//

struct Amount {
    let value: Int
    var isSelected: Bool

    init(value: Int, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }
}
