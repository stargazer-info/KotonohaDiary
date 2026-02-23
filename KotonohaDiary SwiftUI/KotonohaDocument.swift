//
//  KotonohaDocument.swift
//  KotonohaDiary SwiftUI
//

import Foundation
import UIKit

struct KotonohaDocument: Identifiable, Codable, Equatable {
    var id: String
    var text: String?
    var createdAt: Date
    var hasImage: Bool

    static func == (lhs: KotonohaDocument, rhs: KotonohaDocument) -> Bool {
        lhs.id == rhs.id
    }

    init(id: String = UUID().uuidString, text: String? = nil, createdAt: Date = Date(), hasImage: Bool = false) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.hasImage = hasImage
    }

    var section: String {
        DateFormatUtil.format(date: createdAt)
    }
}
