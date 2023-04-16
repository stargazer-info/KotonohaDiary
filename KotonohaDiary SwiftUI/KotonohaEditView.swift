//
//  KotonohaEditView.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/15.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import SwiftUI

struct KotonohaEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FocusState var isInputActive: Bool
    @State var text: String = ""
    @State var image: Image?
    
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
                        Spacer()
                        Button("Cancel") {
                            isInputActive = false
                        }
                    }
                }
                .onSubmit {
                    createOrUpdateKotonoha()
                }
            Button("Save") {
                createOrUpdateKotonoha()
            }
            .buttonStyle(.borderless)
        }
    }
    
    private func createOrUpdateKotonoha() {
        do {
            if !text.isEmpty {
                let newItem = Kotonoha(context: viewContext)
                newItem.text = text
            }
            clear()
            isInputActive = false
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func clear() {
        text = ""
        image = nil
    }
}

struct KotonohaEditView_Previews: PreviewProvider {
    static var previews: some View {
        KotonohaEditView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
