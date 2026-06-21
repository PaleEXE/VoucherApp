//
//  Operator.swift
//  EVoucher
//
//  Created by test on 18/06/2026.
//
import UIKit

class Operator {
    let name: String
    let logo: UIImage
    var isSelected: Bool

    init(name: String, logoPath: String, isSelected: Bool = false) {
        self.logo = UIImage(named: logoPath) ?? UIImage()
        self.name = name
        self.isSelected = isSelected
    }
}
