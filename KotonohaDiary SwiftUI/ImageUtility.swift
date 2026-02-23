//
//  ImageUtility.swift
//  KotonohaDiary SwiftUI
//

import UIKit

struct ImageUtility {
    static let shortSideSize: CGFloat = 640
    static let jpegQuality: CGFloat = 0.5

    static func jpegData(from image: UIImage) -> Data {
        let resized = resize(image: image)
        return resized.jpegData(compressionQuality: jpegQuality) ?? Data()
    }

    static func resize(image: UIImage) -> UIImage {
        let size = image.size
        let shortSide = min(size.width, size.height)
        let scale = shortSideSize / shortSide
        guard scale < 1 else { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
