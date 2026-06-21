//
//  Operator.swift
//  EVoucher
//
//  Created by test on 18/06/2026.
//
import UIKit

struct Operator {
    let name: String
    let logo: UIImage

    init(name: String, logoPath: String) {
        self.logo = UIImage(named: logoPath) ?? UIImage()
        self.name = name
    }
}
