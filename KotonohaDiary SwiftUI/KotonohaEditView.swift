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
    @EnvironmentObject var kotonohaController: KotonohaController
    @FocusState var isInputActive: Bool
    @Binding var kotonoha: Kotonoha?
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
                Label("Toggle Selected", image: "unselected")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
            TextField("ことのは", text: $text)
                .border(.gray)
                .focused($isInputActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            isInputActive = false
                            isChooseImageConfirming = true
                        } label: {
                            Label("", systemImage: "camera")
                                .labelStyle(.iconOnly)
                        }
                        .confirmationDialog("Choose Image", isPresented: $isChooseImageConfirming) {
                            ImageSelectConfirmationDialog(showCameraPicker: $showCameraPicker, showPhotoLibraryPicker: $showPhotoLibraryPicker)
                        }
                        Spacer()
                        Button("Cancel") {
                            clear()
                            isInputActive = false
                        }
                    }
                }
                .onSubmit {
                    createOrUpdateKotonoha()
                    clear()
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
        .onChange(of: kotonoha) {newValue in
            text = newValue?.text ?? ""
            isInputActive = !text.isEmpty
        }
    }
    
    private func createOrUpdateKotonoha() {
        do {
            if !text.isEmpty {
                if let kotonoha = kotonoha, kotonoha.text != text {
                    kotonohaController.update(text: text, kotonoha: kotonoha)
                } else {
                    kotonohaController.create(text: text)
                }
            }
            if let image = self.image {
                kotonohaController.create(image: image)
            }
            try kotonohaController.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func clear() {
        kotonoha = nil
        text = ""
        image = nil
    }
}

struct KotonohaEditView_Previews: PreviewProvider {
    @State static var kotonoha: Kotonoha?
    
    static var previews: some View {
        KotonohaEditView(kotonoha: $kotonoha)
            .environmentObject(KotonohaController(context: PersistenceController.preview.container.viewContext))
    }
}
