//
//  ImageUtility.swift
//  KotonohaDiary SwiftUI
//

import UIKit

struct ImageUtility {
    /// 保存時の JPEG 品質（オリジナルに近い品質で保存）
    static let jpegQuality: CGFloat = 0.9

    /// サムネイル表示用の短辺サイズ
    static let thumbnailShortSide: CGFloat = 640

    // MARK: - 保存用（リサイズなし）

    static func jpegData(from image: UIImage) -> Data {
        return image.jpegData(compressionQuality: jpegQuality) ?? Data()
    }

    // MARK: - サムネイル用（表示時に使う）

    static func thumbnail(from image: UIImage) -> UIImage {
        let size = image.size
        let shortSide = min(size.width, size.height)
        let scale = thumbnailShortSide / shortSide
        guard scale < 1 else { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
