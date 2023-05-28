//
//  ImageSelectConfirmationDialog.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/05/28.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI
//import PhotosUI

struct ImageSelectConfirmationDialog: View {
    @Binding var showCameraPicker: Bool
    @Binding var showPhotoLibraryPicker: Bool
    
    var body: some View {
        Button("Camera") {
            showCameraPicker = true
        }
        Button("Gallery") {
            showPhotoLibraryPicker = true
        }
        Button("Cancel", role: .cancel) {
            
        }
    }
}

struct ImageSelectConfirmationDialog_Previews: PreviewProvider {
    @State static var showCameraPicker = false
    @State static var showPhotoLibraryPicker = false
    
    static var previews: some View {
        ImageSelectConfirmationDialog(showCameraPicker: $showCameraPicker, showPhotoLibraryPicker: $showPhotoLibraryPicker)
    }
}
