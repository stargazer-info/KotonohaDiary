//
//  UIKitTextField.swift
//  KotonohaDiary SwiftUI
//

import SwiftUI
import UIKit

/// SwiftUI の TextField は IME 未確定文字（marked text）が祖先ビューの再描画で
/// 強制確定されてしまうため、UITextField をラップして composition を保護する。
struct UIKitTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    var placeholder: String
    var onSubmit: () -> Void
    var onCamera: () -> Void
    var onCancel: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.font = .preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.inputAccessoryView = makeAccessoryToolbar(coordinator: context.coordinator)
        return textField
    }

    /// キーボード上部に表示するカメラ／キャンセルのツールバー。
    /// SwiftUI の `.toolbar(placement: .keyboard)` は @FocusState 連動のため
    /// UITextField では表示されないので、inputAccessoryView で代替する。
    private func makeAccessoryToolbar(coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar()
        let camera = UIBarButtonItem(
            image: UIImage(systemName: "camera"),
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.cameraTapped)
        )
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: coordinator,
            action: #selector(Coordinator.cancelTapped)
        )
        toolbar.items = [camera, flexible, cancel]
        toolbar.sizeToFit()
        return toolbar
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // クロージャが古い @State を参照しないよう、最新の値で更新する。
        context.coordinator.parent = self

        // IME 未確定中は text を上書きしない（marked text が破壊されるため）。
        if uiView.markedTextRange == nil, uiView.text != text {
            uiView.text = text
        }

        if isFocused != uiView.isFirstResponder {
            DispatchQueue.main.async {
                if isFocused {
                    uiView.becomeFirstResponder()
                } else {
                    uiView.resignFirstResponder()
                }
            }
        }
    }

    /// UITextField は本来 1 行分の高さしか持たないが、UIViewRepresentable のままだと
    /// 提案された縦スペースいっぱいに広がってしまう。intrinsic な高さに固定する。
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextField, context: Context) -> CGSize? {
        let height = uiView.intrinsicContentSize.height
        let width = proposal.width ?? uiView.intrinsicContentSize.width
        return CGSize(width: width, height: height)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UIKitTextField

        init(_ parent: UIKitTextField) {
            self.parent = parent
        }

        @objc func textDidChange(_ textField: UITextField) {
            // IME 未確定中は SwiftUI 側に伝えない。
            // 伝えると @State 更新で再描画され marked text が失われる。
            if textField.markedTextRange != nil { return }
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            if !parent.isFocused {
                parent.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.isFocused {
                parent.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit()
            return true
        }

        @objc func cameraTapped() {
            parent.onCamera()
        }

        @objc func cancelTapped() {
            parent.onCancel()
        }
    }
}
