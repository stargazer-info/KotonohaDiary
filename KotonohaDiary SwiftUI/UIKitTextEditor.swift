//
//  UIKitTextEditor.swift
//  KotonohaDiary SwiftUI
//

import SwiftUI
import UIKit

/// SwiftUI の TextEditor は IME 未確定文字（marked text）が祖先ビューの再描画で
/// 強制確定されてしまうため、UITextView をラップして composition を保護する。
struct UIKitTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.backgroundColor = .clear
        textView.textColor = .label
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // IME 未確定中は text を上書きしない（marked text が破壊されるため）。
        if uiView.markedTextRange == nil, uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextEditor

        init(_ parent: UIKitTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // IME 未確定中は SwiftUI 側に伝えない。
            if textView.markedTextRange != nil { return }
            parent.text = textView.text
        }
    }
}
