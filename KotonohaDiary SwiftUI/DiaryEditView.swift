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
//    @Environment(\.editMode) var editMode
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var diary: Diary?
    @State var editingText: String = ""
    @State var images: [ImageData] = []
    @State var newImage: UIImage?
    @State private var draggingImage: ImageData?
    @State private var isChooseImageConfirming = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibraryPicker = false
    @State var selectedPhotos: PhotosPickerItem?

    var body: some View {
        VStack {
            ScrollView {
                TextEditor(text: $editingText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .onAppear {
                    self.editingText = self.diary?.text ?? ""
                }
            }
            Spacer()
            if let images = diary?.images {
                ScrollView([.horizontal]) {
                    HStack {
                        ForEach(self.images) { imageData in
                            Image(uiImage: imageData.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
//                                .onDrag {
//                                    self.draggingImage = imageData
//                                    return NSItemProvider(object: imageData.id! as NSString)
//                                }
//                                .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: imageData, listData: $images, current: $draggingImage))
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
                .onAppear {
                    if let imageDataList = images.array as? [ImageData] {
                        self.images = imageDataList
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
//        .onAppear {
//            self.editMode?.wrappedValue = .active
//        }
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
                            diary.text = editingText
                            addAllImages(diary: diary)
                            try viewContext.save()
                        }
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
                let newImageData = ImageData(context: viewContext)
                newImageData.image = image
                images.append(newImageData)
                newImage = nil
            }
        }
    }
    
    private func addAllImages(diary: Diary) {
        removeAllImages(diary: diary)
        for image in images {
            diary.addToImages(image)
        }
    }

    private func removeAllImages(diary: Diary) {
        if let images = diary.images?.array as? [ImageData] {
            for image in images {
                diary.removeFromImages(image)
            }
        }
    }

    struct DragRelocateDelegate: DropDelegate {
        let item: ImageData
        @Binding var listData: [ImageData]
        @Binding var current: ImageData?

        func dropEntered(info: DropInfo) {
            if item != current {
                let from = listData.firstIndex(of: current!)!
                let to = listData.firstIndex(of: item)!
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
    @State static var diary = SampleData().diary
    
    static var previews: some View {
        DiaryEditView(diary: $diary)
    }
}
