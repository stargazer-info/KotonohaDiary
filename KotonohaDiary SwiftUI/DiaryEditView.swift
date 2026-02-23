//
//  DiaryEditView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/14.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct DiaryEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryStore: DiaryStore
    var diary: DiaryDocument?
    @State var editingText: String = ""
    @State var images: [EditableImageData] = []
    struct EditableImageData: Identifiable, Equatable {
        var id: UUID = UUID()
        var image: UIImage
    }
    @State var newImage: UIImage?
    @State private var draggingImage: EditableImageData?
    @State private var isChooseImageConfirming = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State var selectedPhotos: PhotosPickerItem?
    @State var isTargeted: Bool = false
    @State var showingImage: EditableImageData?
    @State var isImageDeleted: Bool = false

    init(diary: DiaryDocument) {
        self.diary = diary
        self._editingText = State(initialValue: diary.text)
    }

    init(text: String, images: [UIImage]) {
        self._editingText = State(initialValue: text)
        self._images = State(initialValue: images.map { EditableImageData(image: $0) })
    }

    var body: some View {
        VStack {
            TextEditor(text: $editingText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(.gray, width: 1)
                .padding()
            ScrollView([.horizontal]) {
                LazyHStack {
                    ForEach(self.images) { image in
                        Image(uiImage: image.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .onDrag {
                                self.draggingImage = image
                                return NSItemProvider(object: image.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: DragImageReorderDelegate(item: image, listData: $images, current: $draggingImage)
                            )
                            .onTapGesture {
                                showingImage = image
                            }
                    }
                    Image("addImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .onTapGesture {
                            print("onTapGesture")
                            isChooseImageConfirming = true
                        }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .scrollDisabled(draggingImage != nil)
            .sheet(item: $showingImage) { imageData in
                ImageView(image: imageData.image, showDeleteButton: true, isDeleted: $isImageDeleted)
            }
        }
        .onAppear {
            loadDiaryData()
        }
        .frame(maxWidth: .infinity)
        .background(Image("background"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if let diary = diary {
                        diaryStore.update(diary, text: editingText, images: images.map({ $0.image }))
                    } else {
                        diaryStore.create(text: editingText, images: images.map({ $0.image }))
                    }
                    dismiss()
                }
            }
        }
        .confirmationDialog("Choose Image", isPresented: $isChooseImageConfirming) {
            ImageSelectConfirmationDialog(showCameraPicker: $showCameraPicker, showPhotoLibraryPicker: $showPhotoLibraryPicker)
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPicker(image: $newImage)
        }
        .photosPicker(isPresented: $showPhotoLibraryPicker, selection: $selectedPhotos, matching: .images)
        .onChange(of: selectedPhotos) { newValue in
            Task {
                if let imageData = try? await newValue?.loadTransferable(type: Data.self) {
                    newImage = UIImage(data: imageData)
                }
                selectedPhotos = nil
            }
        }
        .onChange(of: newImage) { newValue in
            if let image = newValue {
                images.append(EditableImageData(image: image))
                newImage = nil
            }
        }
        .onChange(of: isImageDeleted) { newValue in
            if newValue, let image = showingImage {
                self.isImageDeleted = false
                self.showingImage = nil
                self.images = self.images.filter({ $0 != image })
            }
        }
    }

    private func loadDiaryData() {
        if let diary = diary {
            self.images = diaryStore.loadImages(for: diary).map { EditableImageData(image: $0) }
            self.editingText = diary.text
        }
    }

    struct DragImageReorderDelegate: DropDelegate {
        let item: EditableImageData
        @Binding var listData: [EditableImageData]
        @Binding var current: EditableImageData?

        func dropEntered(info: DropInfo) {
            if item != current, let from = listData.firstIndex(of: current!), let to = listData.firstIndex(of: item) {
                if listData[to].id != current!.id {
                    listData.move(fromOffsets: IndexSet(integer: from),
                        toOffset: to > from ? to + 1 : to)
                }
            }
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }

        func performDrop(info: DropInfo) -> Bool {
            self.current = nil
            return true
        }
    }
}

struct DiaryEditView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryEditView(text: "テスト", images: [])
            .environmentObject(DiaryStore())
    }
}
