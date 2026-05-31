//
//  KotonohaEditView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI
import PhotosUI

struct KotonohaEditView: View {
    @EnvironmentObject var kotonohaStore: KotonohaStore
    @State var isInputActive: Bool = false
    @Binding var kotonoha: KotonohaDocument?
    @State var text: String = ""
    @State var image: UIImage?
    @State private var isChooseImageConfirming = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State private var selectedPhotos: PhotosPickerItem?

    var body: some View {
        HStack {
            Button {
            } label: {
                Label(String(""), image: "unselected")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            UIKitTextField(
                text: $text,
                isFocused: $isInputActive,
                placeholder: String(localized: "Words"),
                onSubmit: {
                    createOrUpdateKotonoha()
                    clear()
                },
                onCamera: {
                    isInputActive = false
                    isChooseImageConfirming = true
                },
                onCancel: {
                    clear()
                    isInputActive = false
                }
            )
                .border(.gray)
                .confirmationDialog("Choose Image", isPresented: $isChooseImageConfirming) {
                    ImageSelectConfirmationDialog(showCameraPicker: $showCameraPicker, showPhotoLibraryPicker: $showPhotoLibraryPicker)
                }
            Button("Save") {
                createOrUpdateKotonoha()
                clear()
            }
            .buttonStyle(.borderless)
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPicker(image: $image)
        }
        .photosPicker(isPresented: $showPhotoLibraryPicker, selection: $selectedPhotos, matching: .images)
        .onChange(of: selectedPhotos) { newValue in
            Task {
                if let imageData = try? await newValue?.loadTransferable(type: Data.self) {
                    image = UIImage(data: imageData)
                }
                selectedPhotos = nil
            }
        }
        .onChange(of: image) { newValue in
            createOrUpdateKotonoha()
            clear()
        }
        .onChange(of: kotonoha) { newValue in
            text = newValue?.text ?? ""
            isInputActive = !text.isEmpty
        }
    }

    private func createOrUpdateKotonoha() {
        if !text.isEmpty {
            if let kotonoha = kotonoha, kotonoha.text != text {
                kotonohaStore.update(text: text, kotonoha: kotonoha)
            } else {
                kotonohaStore.create(text: text)
            }
        }
        if let image = self.image {
            kotonohaStore.create(image: image)
        }
    }

    private func clear() {
        kotonoha = nil
        text = ""
        image = nil
    }
}

struct KotonohaEditView_Previews: PreviewProvider {
    @State static var kotonoha: KotonohaDocument?

    static var previews: some View {
        KotonohaEditView(kotonoha: $kotonoha)
            .environmentObject(KotonohaStore())
    }
}
