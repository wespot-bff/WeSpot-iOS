//
//  UITextField+Extensions.swift
//  Extensions
//
//  Created by 김도현 on 5/30/25.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: UITextField {
    public var changedText: ControlProperty<String?> {
            return base.rx.controlProperty(editingEvents: [.editingChanged, .valueChanged], getter: { textField in
                textField.text
            }, setter: { textField, value in
                if textField.text != value {
                    textField.text = value
                }
            })
        }
}
