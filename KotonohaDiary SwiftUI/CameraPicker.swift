//
//  CameraView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/03.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = .camera

        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
            parent.image = image
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
