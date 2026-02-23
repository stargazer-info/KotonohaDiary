//
//  DiaryDocument.swift
//  KotonohaDiary SwiftUI
//

import Foundation
import UIKit

struct DiaryDocument: Identifiable, Codable, Equatable {
    var id: String
    var text: String
    var createdAt: Date
    var imageFilenames: [String]

    static func == (lhs: DiaryDocument, rhs: DiaryDocument) -> Bool {
        lhs.id == rhs.id
    }

    init(id: String = UUID().uuidString, text: String = "", createdAt: Date = Date(), imageFilenames: [String] = []) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.imageFilenames = imageFilenames
    }
}
