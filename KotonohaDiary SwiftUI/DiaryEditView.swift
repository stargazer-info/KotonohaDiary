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
    @EnvironmentObject var diaryController: DiaryController
    var diary: Diary?
    @State var editingText: String = ""
    @State var images: [ImageData] = []
    @State var newImage: UIImage?
    @State private var draggingImage: ImageData?
    @State private var isChooseImageConfirming = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State var selectedPhotos: PhotosPickerItem?
    @State var isTargeted: Bool = false
    @State var showingImage: ImageData?
    @State var deletedImage: ImageData?

    var body: some View {
        VStack {
            TextEditor(text: $editingText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(.gray, width: 1)
                .padding()
            ScrollView([.horizontal]) {
                HStack {
                    ForEach(self.images) { imageData in
                        Image(uiImage: imageData.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .onDrag {
                                self.draggingImage = imageData
                                return NSItemProvider(object: imageData.id! as NSString)
                            }
                            .onDrop(of: [.text], delegate: DragImageReorderDelegate(item: imageData, listData: $images, current: $draggingImage))
                            .onTapGesture {
                                showingImage = imageData
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
            .sheet(item: $showingImage) { imageData in
                ImageView(imageData: imageData, showDeleteButton: true, deletedImage: $deletedImage)
            }
        }
        .onAppear {
            update(diary: diary)
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
                    do {
                        if let diary = diary {
                            diaryController.update(diary, text: editingText, images: images.map({ $0.image }))
                        } else {
                            diaryController.create(text: editingText, images: images.map({ $0.image }))
                        }
                        try diaryController.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    update(diary: diary)
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
                let newImageData = diaryController.createImageData(image)
                images.append(newImageData)
                newImage = nil
            }
        }
        .onChange(of: deletedImage) { newValue in
            if let image = newValue {
                self.images = self.images.filter({ $0 != image })
                deletedImage = nil
            }
        }
    }
    
    private func update(diary: Diary?) {
        if let diary = diary {
            self.images = (diary.images?.array as? [ImageData]) ?? []
            self.editingText = diary.text ?? ""
        }
    }
    
    struct DragImageReorderDelegate: DropDelegate {
        let item: ImageData
        @Binding var listData: [ImageData]
        @Binding var current: ImageData?

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
        DiaryEditView(diary: SampleData().diary)
            .environmentObject(DiaryController(context: PersistenceController.preview.container.viewContext))
    }
}
