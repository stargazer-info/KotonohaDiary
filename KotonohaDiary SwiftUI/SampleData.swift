//
//  SampleData.swift
//  KotonohaDiary SwiftUI
//
//  Created by 山口 伸行 on 2023/04/09.
//  Copyright © 2023 Stargazer Information. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import Combine

class SampleData: ObservableObject {
    let context = PersistenceController.preview.container.viewContext

    var kotonoha: Kotonoha
    var kotonohaImage: Kotonoha
    var diary: Diary?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Kotonoha.createdAt, ascending: true)],
        animation: .default)
    var kotonohaList: FetchedResults<Kotonoha>

    init() {
//        let kotonohaController = KotonohaController(context: context)
//        let diaryController = DiaryController(context: context)
        let kotonoha = Kotonoha(context: context)
        kotonoha.text = "テスト"
        self.kotonoha = kotonoha

        let imageEntity = ImageData(context: context)
        imageEntity.image = UIImage(named: "AppIconDebug")!
        let kotonohaImage = Kotonoha(context: context)
        kotonohaImage.image = imageEntity
        self.kotonohaImage = kotonohaImage
        
        self.diary = createDiary()
    }
    
    private func createDiary() -> Diary {
        let diary = Diary(context: context)
        diary.text = """
日記テスト
複数行
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ
いいいいいいいいいいいいいいいいいいいいいいいいいいい
ううううううううううううううううううううううううううう
えええええええええええええええええええええええええええ
おおおおおおおおおおおおおおおおおおおおおおおおおおお
"""
//        for i in 0..<10 {
        for i in 0..<2 {
            let imageEntity = ImageData(context: context)
            imageEntity.image = UIImage(named: "AppIconDebug")!
            diary.addToImages(imageEntity)
        }
        return diary
    }
}
