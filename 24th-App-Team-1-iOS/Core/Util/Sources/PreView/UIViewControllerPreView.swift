//
//  UIViewControllerPreview.swift
//  Util
//
//  Created by 최지철 on 11/22/24.
//

import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI

public struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    // MARK: - Properties
    private let builder: () -> ViewController

    // MARK: - Initializer
    public init(_ builder: @escaping () -> ViewController) {
        self.builder = builder
    }

    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> ViewController {
        return builder()
    }

    public func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No update required for static previews
    }
}
#endif
